//
//  RequestPanelView.swift
//  StoreKit2TestApp
//
//  Created by AL02528306 on 8/1/25.
//
import SwiftUI
import StoreKit

struct RequestPanelView: View {
    @Binding var isProductFetchOn: Bool
    @Binding var isPurchaseOn: Bool
    @Binding var isCompletionOn: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            ToggleCardView(title: "상품 조회", isOn: $isProductFetchOn)
            ToggleCardView(title: "인앱 결제", isOn: $isPurchaseOn)
            ToggleCardView(title: "결제 완료", isOn: $isCompletionOn)
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
