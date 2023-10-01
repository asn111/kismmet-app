//
//  IAPManager.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 05/04/2023.
//

import Foundation
import StoreKit
import SwiftyStoreKit



class IAPManager: NSObject {
    
    static let shared = IAPManager()
    //kissmet_premium_s1 ///Group Reference Name
    //kismmet_premium_s1_shadow_mode ///Product ID
    let monthlySubID = "kismmet_premium_s1_shadow_mode"
    let app_Specific_Shared_Secret = "b629c35cb3a34bf5b1a92351f2bb9338"
    var products: [String: SKProduct] = [:]
    
    
    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    func fetchProducts() {
        let productIDs = Set([monthlySubID])
        let request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()
    }
    
    func purchase(productID: String) {
        if let product = products[productID] {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func showManageSubscriptions() {
        if let url = URL(string: "itms-apps://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func checkSubscriptionStatus() {
        SwiftyStoreKit.fetchReceipt(forceRefresh: true) { result in
            switch result {
                case .success(let receiptData):
                    let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: self.app_Specific_Shared_Secret)
                    SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
                        switch result {
                            case .success(let receipt):
                                let purchaseResult = SwiftyStoreKit.verifySubscription(
                                    ofType: .autoRenewable,
                                    productId: self.monthlySubID,
                                    inReceipt: receipt)
                                
                                switch purchaseResult {
                                    case .purchased(let expiryDate, _):
                                        Logs.show(message: "Subscription is valid until \(expiryDate)")
                                        // Update the app state to reflect that the user is subscribed
                                    case .expired(let expiryDate):
                                        Logs.show(message: "Subscription expired on \(expiryDate)")
                                        ApiService.updateSubscription(val: freeSubscriptionId)
                                        AppFunctions.setIsPremiumUser(value: false)
                                        // Update the app state to reflect that the user is not subscribed
                                    case .notPurchased:
                                        Logs.show(message: "The user has never purchased this subscription")
                                        // Update the app state to reflect that the user is not subscribed
                                        AppFunctions.setIsPremiumUser(value: false)
                                }
                                
                            case .error(let error):
                                Logs.show(message: "Receipt verification failed: \(error)")
                        }
                    }
                    
                case .error(let error):
                    Logs.show(message: "Receipt refresh failed: \(error)")
            }
        }
    }

}

extension IAPManager: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        response.invalidProductIdentifiers.forEach { product in
            Logs.show(message: "Invalid: \(product)")
        }
        products.removeAll()
        response.products.forEach { product in
            Logs.show(message: "Valid: \(product)")
            products[product.productIdentifier] = product
        }
        
        productPublisher.onNext(products)
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error for request: \(error.localizedDescription)")
    }
    
    func requestDidFinish(_ request: SKRequest) {
        // Implement this method OPTIONALLY and add any custom logic
        // you want to apply when a product request is finished.
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { (transaction) in
            switch transaction.transactionState {
                case .purchased:
                    Logs.show(message: "onBuyProductHandler TRUE: \(transaction)")
                    handleSuccessfulPurchase(transaction)

                    
                case .restored:
                    Logs.show(message: "restored: \(transaction)")
                    SKPaymentQueue.default().finishTransaction(transaction)
                    
                case .failed:
                    if let error = transaction.error as? SKError {
                        if error.code != .paymentCancelled {
                            Logs.show(message: "IAP Error paymentNotCancelled: \(error)")
                        } else {
                            Logs.show(message: "IAP Error paymentCancelled: \(error)")

                        }
                    }
                    SKPaymentQueue.default().finishTransaction(transaction)
                    
                case .deferred, .purchasing: break
                @unknown default: break
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        Logs.show(message: "IAP: purchases to restore: \(queue.transactions)")
    }
    
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        if let error = error as? SKError {
            if error.code != .paymentCancelled {
                print("IAP  Error:", error.localizedDescription)
                Logs.show(message: "IAP Error Restore paymentNotCancelled: \(error)")
            } else {
                Logs.show(message: "IAP Error Restore paymentCancelled: \(error)")
            }
        }
    }
    
    func handleSuccessfulPurchase(_ transaction: SKPaymentTransaction) {
        // Process the successful purchase here
        // You can get the transaction id and receipt data as follows:
        if let url = Bundle.main.appStoreReceiptURL,
           let data = try? Data(contentsOf: url) {
            let receiptBase64 = data.base64EncodedString()
            // Send the receipt data to your server for validation
            Logs.show(message: "appStoreReceiptURL: \(url)")
            generalPublisher.onNext("purchased")

            ApiService.updateSubscription(val: premiumSubscriptionId)
            AppFunctions.setIsPremiumUser(value: true)
        }
        Logs.show(message: "transaction Successful: \(transaction)")
        // Finish the transaction
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
}
