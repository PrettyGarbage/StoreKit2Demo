//
//  ToggleCard.swift
//  StoreKit2TestApp
//
//  Created by AL02528306 on 8/1/25.
//
import SwiftUI
import StoreKit

struct StoreKitPanelView: View {
    @ObservedObject var viewModel: StoreViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            VStack(alignment: .leading, spacing: 8) {
                Toggle(isOn: $viewModel.useStoreKit2) {
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
            
            //MARK: - 선택 상품 드롭다운
            VStack(alignment: .leading, spacing: 12) {
                Picker("Select Product", selection: $viewModel.selectedProductID) {
                    Text("None").tag(nil as String?) //add nil tag
                    
                    ForEach(viewModel.products, id: \.id) { product in
                        Text(product.displayName).tag(product.id as String?)
                    }
                }
                .pickerStyle(.menu)
                
                if let selected = viewModel.selectedProduct {
                    Text("select product :\(selected.displayName)")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(1), lineWidth: 1)
            )
            
            //MARK: - 복구 상품 트랜젝션 드롭다운
            VStack(alignment: .leading, spacing: 12) {
                Picker("Select Transaction", selection: $viewModel.selectedTransactionID) {
                    Text("None").tag(nil as String?) //add nil tag
                    
                    ForEach(viewModel.uncompletedTransactions, id: \.id) { tx in
                        Text("Item : \(tx.productID)").tag(tx.productID as String?)
                    }
                }
                .pickerStyle(.menu)
                
                if let selected = viewModel.selectedTransaction {
                    Text("select Transaction :\(String(describing: selected.id ))")
                        .font(.caption)
                        .foregroundStyle(.gray)
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
