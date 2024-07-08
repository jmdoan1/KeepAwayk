//
//  SubscriptionPopupView.swift
//  KeepAwayk
//
//  Created by Justin Doan on 7/8/24.
//

import Foundation
import SwiftUI

struct SubscriptionPopupView: View {
    @Binding var isVisible: Bool
    
    var body: some View {
        VStack {
            Text("Subscribe to access this feature!")
                .font(.headline)
                .padding()
            
            Button(action: {
                // Handle subscription action
                isVisible = false
            }) {
                Text("Subscribe Now")
                    .padding()
                    .foregroundColor(.white)
                    .font(.title2)
            }
            .background(Color.blue)
            .cornerRadius(10)
            
            Button(action: {
                isVisible = false
            }) {
                Text("Cancel")
                    .padding()
            }
        }
        .frame(width: 300, height: 200)
//        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}
