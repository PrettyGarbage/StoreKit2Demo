//
//  ActionPanelView.swift
//  StoreKit2TestApp
//
//  Created by AL02528306 on 8/6/25.
//

import SwiftUI
import StoreKit

// MARK: - Action Panal
public struct ActionPanelView: View {
    @ObservedObject var viewModel: StoreViewModel
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Action Panel")
                .font(.headline)
                .foregroundColor(.white)
            
            ButtonCardView(title: "단품 구매") {
                Task{
                    await viewModel.purchaseSelectedProduct()
                }
            }
            
            ButtonCardView(title: "상품 복구") {
                Task{
                    await viewModel.restorePurchases()
                }
            }
            ButtonCardView(title: "복구 상품 구매 완료") {
                Task {
                    await viewModel.finishTransaction()
                }
            }
            ButtonCardView(title: "모든 트랜잭션 불러오기") {
                Task {
                    await viewModel.loadAllTransactions()
                }
            }
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
