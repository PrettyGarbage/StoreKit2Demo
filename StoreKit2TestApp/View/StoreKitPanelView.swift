//
//  ToggleCard.swift
//  StoreKit2TestApp
//
//  Created by AL02528306 on 8/1/25.
//
import SwiftUI
import StoreKit

struct StoreKitPanelView: View {
    @Binding var useStoreKit2: Bool
    @Binding var selectedProduct: Product?
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            VStack(alignment: .leading, spacing: 8) {
                Toggle(isOn: $useStoreKit2) {
                    Text("Use StoreKit2")
                        .foregroundColor(.white)
                }
                .toggleStyle(SwitchToggleStyle(tint: .blue))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(1), lineWidth: 1)
            )
            
            VStack(alignment: .leading, spacing: 12) {
                if let selected = selectedProduct {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selected.displayName)
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                } else {
                    Text("")
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(1), lineWidth: 1)
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.3))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(1), lineWidth: 1)
        )
    }
}
