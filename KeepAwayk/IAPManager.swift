//
//  IAPManager.swift
//  KeepAwayk
//
//  Created by Justin Doan on 7/8/24.
//

import Foundation
import StoreKit

protocol IAPManagerDelegate: AnyObject {
    func didPurchaseSubscription()
}

class IAPManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver, ObservableObject {
    static let shared = IAPManager()
    weak var delegate: IAPManagerDelegate?
    private override init() {}
    
    @Published var products: [SKProduct] = []
    @Published var hasSubscription = false
    
    let productIdentifiers: Set<String> = ["com.keepawayk.weekly", "com.keepawayk.monthly", "com.keepawayk.quarterly", "com.keepawayk.6month","com.keepawayk.annual"]
    
    func fetchProducts() {
        if products.count < 1 {
            let request = SKProductsRequest(productIdentifiers: productIdentifiers)
            request.delegate = self
            request.start()
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            let prods = response.products.sorted { $0.price.doubleValue < $1.price.doubleValue }
            self.products = prods
            
            prods.forEach { prod in
                Task {
                    await self.checkStatus(identifier: prod.productIdentifier)
                }
            }
        }
    }
    
    func checkStatus(identifier: String) async {
        do {
            let result = try await Product.SubscriptionInfo.status(for: identifier)
            let allowableStates: [Product.SubscriptionInfo.RenewalState] = [.subscribed, .inGracePeriod, .inBillingRetryPeriod]
            for stat in result {
                print("\(identifier): \(stat.state)")
                if allowableStates.contains(where: { x in
                    x == stat.state
                }) {
                    self.hasSubscription = true
                }
            }
            print("\(identifier) STATUSES:", result)
        } catch {
            print("Couldn't determine subscription status")
        }
    }
    
    func buyProduct(_ product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func handlePurchasedTransaction(_ transaction: SKPaymentTransaction) {
        print("Subscription purchased successfully!")
        hasSubscription = true
        delegate?.didPurchaseSubscription()
    }
    
    func handleFailedTransaction(_ transaction: SKPaymentTransaction) {
        if let error = transaction.error as NSError?, error.code != SKError.paymentCancelled.rawValue {
            print("Transaction failed: \(error.localizedDescription)")
        } else {
            print("Transaction cancelled by user")
        }
    }
    
    func handleRestoredTransaction(_ transaction: SKPaymentTransaction) {
        print("Subscription restored successfully!")
        hasSubscription = true
        delegate?.didPurchaseSubscription()
    }
}
