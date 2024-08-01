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
        guard let product = products[productID] else {
            Logs.show(message: "Product not found: \(productID)")
            return
        }
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func showManageSubscriptions() {
        guard let url = URL(string: "itms-apps://apps.apple.com/account/subscriptions") else {
            Logs.show(message: "Failed to create subscriptions URL")
            return
        }
        UIApplication.shared.open(url, options: [:]) { success in
            if !success {
                Logs.show(message: "Failed to open subscriptions URL")
            }
        }
    }
    
    func checkSubscriptionStatus() {
        SwiftyStoreKit.fetchReceipt(forceRefresh: true) { result in
            switch result {
                case .success(let receiptData):
                    let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: self.app_Specific_Shared_Secret)
                    SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
                        self.handleReceiptVerification(result: result)
                    }
                case .error(let error):
                    Logs.show(message: "Receipt refresh failed: \(error.localizedDescription)")
                    // Consider showing user-friendly error message
            }
        }
    }
    
    private func handleReceiptVerification(result: VerifyReceiptResult) {
        switch result {
            case .success(let receipt):
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable,
                    productId: self.monthlySubID,
                    inReceipt: receipt
                )
                self.handleSubscriptionVerification(result: purchaseResult)
            case .error(let error):
                Logs.show(message: "Receipt verification failed: \(error.localizedDescription)")
                // Consider showing user-friendly error message
        }
    }
    
    private func handleSubscriptionVerification(result: VerifySubscriptionResult) {
        switch result {
            case .purchased(let expiryDate, _):
                Logs.show(message: "Subscription is valid until \(expiryDate)")
                // Update the app state to reflect that the user is subscribed
            case .expired(let expiryDate):
                Logs.show(message: "Subscription expired on \(expiryDate)")
                if AppFunctions.isLoggedIn() {
                    ApiService.updateSubscription(val: freeSubscriptionId)
                    AppFunctions.setIsPremiumUser(value: false)
                }
                // Update the app state to reflect that the user is not subscribed
            case .notPurchased:
                Logs.show(message: "The user has never purchased this subscription")
                // Update the app state to reflect that the user is not subscribed
                AppFunctions.setIsPremiumUser(value: false)
        }
    }
    
    private func showUserAlert(title: String, message: String) {
        // Utility function to show user alerts
        DispatchQueue.main.async {
            if let topVC = UIApplication.shared.keyWindow?.rootViewController {
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                topVC.present(alert, animated: true)
            }
        }
    }
}

extension IAPManager: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        response.invalidProductIdentifiers.forEach { product in
            Logs.show(message: "Invalid product identifier: \(product)")
        }
        products.removeAll()
        response.products.forEach { product in
            Logs.show(message: "Valid product: \(product)")
            products[product.productIdentifier] = product
        }
        
        // Notify observers or UI components if necessary
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        Logs.show(message: "Failed to fetch products: \(error.localizedDescription)")
        // Consider showing user-friendly error message
    }
    
    func requestDidFinish(_ request: SKRequest) {
        // Optional: Add any custom logic you want to apply when a product request is finished
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { transaction in
            switch transaction.transactionState {
                case .purchased:
                    Logs.show(message: "Purchase successful: \(transaction)")
                    handleSuccessfulPurchase(transaction)
                case .restored:
                    Logs.show(message: "Purchase restored: \(transaction)")
                    handleSuccessfulRestore(transaction)
                case .failed:
                    if let error = transaction.error as? SKError {
                        handlePurchaseError(error)
                    }
                    SKPaymentQueue.default().finishTransaction(transaction)
                case .deferred, .purchasing:
                    break
                @unknown default:
                    break
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        Logs.show(message: "Restored completed transactions: \(queue.transactions)")
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        if let error = error as? SKError {
            handlePurchaseError(error)
        }
    }
    
    private func handleSuccessfulPurchase(_ transaction: SKPaymentTransaction) {
        guard let url = Bundle.main.appStoreReceiptURL else {
            Logs.show(message: "Failed to get receipt URL")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let receiptBase64 = data.base64EncodedString()
            Logs.show(message: "App Store receipt URL: \(url)")
            generalPublisher.onNext("purchased")
            if AppFunctions.isLoggedIn() {
                ApiService.updateSubscription(val: premiumSubscriptionId)
                AppFunctions.setIsPremiumUser(value: true)
            }
        } catch {
            Logs.show(message: "Failed to read receipt data: \(error.localizedDescription)")
        }
        Logs.show(message: "Transaction successful: \(transaction)")
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func handleSuccessfulRestore(_ transaction: SKPaymentTransaction) {
        Logs.show(message: "Transaction restored: \(transaction)")
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func handlePurchaseError(_ error: SKError) {
        switch error.code {
            case .paymentCancelled:
                Logs.show(message: "Payment cancelled: \(error.localizedDescription)")
                // Consider showing user-friendly message
            default:
                Logs.show(message: "Payment error: \(error.localizedDescription)")
                // Consider showing user-friendly error message
        }
    }
}
