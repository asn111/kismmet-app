//
//  IAPManager.swift
//  Kismat App
//
//  Created by Ahsan Iqbal on 05/04/2023.
//

import Foundation
import StoreKit



class IAPManager: NSObject {

    static let shared = IAPManager()
    let monthlySubID = "kissmet_premium_sub_1"
    var products: [String: SKProduct] = [:]
    
    private override init() {
        super.init()
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
    
    func getAllActiveSubscriptions() {
        let paymentQueue = SKPaymentQueue.default()
        paymentQueue.restoreCompletedTransactions()
        
        for transaction in paymentQueue.transactions {
            if transaction.transactionState == .purchased || transaction.transactionState == .restored {
                let productID = transaction.payment.productIdentifier
                if SKPaymentQueue.canMakePayments() {
                    let productRequest: SKProductsRequest = SKProductsRequest(productIdentifiers: Set([productID]))
                    Logs.show(message: "productRequest: \(productRequest)")

                    /*productRequest.start { (response, error) in
                        if error != nil {
                            print("Error fetching product info: \(error?.localizedDescription ?? "")")
                        } else if let product = response?.products.first {
                            // Here, you can access the subscription information such as the product ID, price, and other details.
                            print("Active subscription found: \(product.productIdentifier)")
                        }
                    }*/
                } else {
                    Logs.show(message: " Not canMakePayments:")
                }
            }
        }
    }
}

extension IAPManager: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        response.invalidProductIdentifiers.forEach { product in
            Logs.show(message: "InValid: \(product)")
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
                    SKPaymentQueue.default().finishTransaction(transaction)
                    
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
    
}
