//
//  SubscriptionPopupView.swift
//  KeepAwayk
//
//  Created by Justin Doan on 7/8/24.
//

import Foundation
import SwiftUI
import StoreKit

struct SubscriptionPopupView: View {
    @Binding var isVisible: Bool
    @StateObject private var iapManager = IAPManager.shared
    
    var body: some View {
        VStack {
            Text("Subscribe to disable specific behaviours")
                .font(.headline)
                .padding()
            
            ForEach(iapManager.products, id: \.productIdentifier) { product in
                Button("Buy \(product.localizedTitle) - \(product.priceLocale.currencySymbol!)\(product.price)") {
                    iapManager.buyProduct(product)
                }
            }
            
            Button("Restore Purchases") {
                iapManager.restorePurchases()
            }.padding()
            
            Button("Cancel") {
                isVisible = false
            }.padding()
        }
        .cornerRadius(10)
        .shadow(radius: 10)
        .onAppear {
            IAPManager.shared.fetchProducts()
        }
    }
}
