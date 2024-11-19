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
        Logs.show(message: "Fetching products for IDs: \(productIDs)")
        request.start()
    }
    
    func purchase(productID: String) {
        Logs.show(message: "Attempting to purchase product with ID: \(productID)")
        
        guard let product = products[productID] else {
            Logs.show(message: "Product not found in the products dictionary: \(productID)")
            return
        }
        
        Logs.show(message: "Product found, initiating purchase for: \(product.productIdentifier)")
        
        
        SwiftyStoreKit.fetchReceipt(forceRefresh: true) { result in
            switch result {
                case .success(let receiptData):
                    let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: self.app_Specific_Shared_Secret)
                    SwiftyStoreKit.verifyReceipt(using: appleValidator) { verifyResult in
                        switch verifyResult {
                            case .success(let receipt):
                                let subscriptionResult = SwiftyStoreKit.verifySubscription(
                                    ofType: .autoRenewable,
                                    productId: productID,
                                    inReceipt: receipt
                                )
                                switch subscriptionResult {
                                    case .purchased(let expiryDate, _):
                                        Logs.show(message: "Subscription is still valid until \(expiryDate). No need to repurchase.")
                                        self.showUserAlert(title: "Already Subscribed", message: "Your subscription is valid until \(expiryDate).")
                                    case .expired, .notPurchased:
                                        let payment = SKPayment(product: product)
                                        SKPaymentQueue.default().add(payment)
                                }
                            case .error(let error):
                                Logs.show(message: "Receipt verification failed: \(error.localizedDescription)")
                                self.showUserAlert(title: "Error", message: "Could not verify receipt. Please try again.")
                        }
                    }
                case .error(let error):
                    Logs.show(message: "Receipt fetch failed: \(error.localizedDescription)")
                    self.showUserAlert(title: "Error", message: "Could not fetch receipt. Please try again.")
            }
        }
    }
    
    func restorePurchases() {
        Logs.show(message: "Restoring purchases...")
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
        }
    }
    
    private func handleSubscriptionVerification(result: VerifySubscriptionResult) {
        switch result {
            case .purchased(let expiryDate, _):
                Logs.show(message: "Subscription is valid until \(expiryDate)")
                AppFunctions.setIsPremiumUser(value: true)
            case .expired(let expiryDate):
                Logs.show(message: "Subscription expired on \(expiryDate)")
                if AppFunctions.isLoggedIn() {
                    ApiService.updateSubscription(val: freeSubscriptionId)
                }
                AppFunctions.setIsPremiumUser(value: false)
            case .notPurchased:
                Logs.show(message: "The user has never purchased this subscription")
                AppFunctions.setIsPremiumUser(value: false)
        }
    }
    
    private func showUserAlert(title: String, message: String) {
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
        
        if let productID = products.keys.first {
            Logs.show(message: "Attempting to purchase the first valid product: \(productID)")
            purchase(productID: productID)
        } else {
            Logs.show(message: "No valid products found to purchase.")
        }
    }

    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        Logs.show(message: "Failed to fetch products: \(error.localizedDescription)")
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        Logs.show(message: "Payment queue updated with transactions: \(transactions)")
        transactions.forEach { transaction in
            Logs.show(message: "Transaction state: \(transaction.transactionState.rawValue)")
            switch transaction.transactionState {
                case .purchased:
                    Logs.show(message: "Purchase successful: \(transaction)")
                    handleSuccessfulPurchase(transaction)
                case .failed:
                    Logs.show(message: "Purchase failed: \(transaction)")
                    if let error = transaction.error as? SKError {
                        handlePurchaseError(error)
                    }
                    SKPaymentQueue.default().finishTransaction(transaction)
                case .restored:
                    Logs.show(message: "Purchase restored: \(transaction)")
                    handleSuccessfulRestore(transaction)
                case .deferred, .purchasing:
                    Logs.show(message: "Transaction deferred or purchasing: \(transaction)")
                @unknown default:
                    Logs.show(message: "Unknown transaction state: \(transaction.transactionState.rawValue)")
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
        Logs.show(message: "Transaction successful: \(transaction)")
        AppFunctions.setIsPremiumUser(value: true)
        generalPublisher.onNext("purchased")
        ApiService.updateSubscription(val: premiumSubscriptionId)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func handleSuccessfulRestore(_ transaction: SKPaymentTransaction) {
        Logs.show(message: "Transaction restored: \(transaction)")
        AppFunctions.setIsPremiumUser(value: true)
        generalPublisher.onNext("purchased")
        ApiService.updateSubscription(val: premiumSubscriptionId)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func handlePurchaseError(_ error: SKError) {
        switch error.code {
            case .paymentCancelled:
                Logs.show(message: "Payment cancelled: \(error.localizedDescription)")
            default:
                Logs.show(message: "Payment error: \(error.localizedDescription)")
        }
    }
}
