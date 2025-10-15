//
//  RequestPanelView.swift
//  StoreKit2TestApp
//
//  Created by AL02528306 on 8/1/25.
//
import SwiftUI
import StoreKit
import DeclaredAgeRange

struct RequestPanelView: View {
    @ObservedObject var viewModel: StoreViewModel
    private let productIDs = ["ct2_apple_app_store_gem100", "ct2_apple_app_store_gem300", "ct2_apple_app_store_gem500"]
    
    //알림을 표시할 윈도우를 가리키는 환경변수
    @Environment(\.requestAgeRange) var requestAgeRange
    
    @MainActor
    func topViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) else { return nil }

        // iOS 15+: keyWindow 대체
        let keyWindow = scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first
        var top = keyWindow?.rootViewController
        while let presented = top?.presentedViewController { top = presented }
        return top
    }
    
    @MainActor
    func activeWindowScene() -> UIWindowScene? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Request Panel")
                .font(.headline)
                .foregroundColor(.white)
            
            ToggleCardView(title: "상품 조회", isOn: $viewModel.isProductFetchOn)
                .onChange(of: viewModel.isProductFetchOn) { oldValue, isOn in
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
            ButtonCardView(title: "연령 정보 요청") {
                Task { @MainActor in
                    guard let vc = topViewController() else { return }
                    await viewModel.onRequestDeclaredAgeRange(presenter: vc)
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
