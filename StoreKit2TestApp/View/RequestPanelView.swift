//
//  RequestPanelView.swift
//  StoreKit2TestApp
//
//  Created by AL02528306 on 8/1/25.
//
import SwiftUI
import StoreKit

struct RequestPanelView: View {
    @ObservedObject var viewModel: StoreViewModel
    private let productIDs = ["ct2_apple_app_store_gem100", "ct2_apple_app_store_gem300", "ct2_apple_app_store_gem500"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Request Panel")
                .font(.headline)
                .foregroundColor(.white)
            
            ToggleCardView(title: "상품 조회", isOn: $viewModel.isProductFetchOn)
                .onChange(of: viewModel.isProductFetchOn) { isOn in
                        if isOn {
                            Task {
                                await viewModel.fetchProducts(with: productIDs)
                            }
                        } else {
                            Task {
                                viewModel.products.removeAll()
                                viewModel.selectedProductID = nil
                            }
                        }
                    }
            ToggleCardView(title: "결제 완료", isOn: $viewModel.isCompletionOn)
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
