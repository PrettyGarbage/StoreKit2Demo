//
//  BottomPanelView.swift
//  StoreKit2TestApp
//
//  Created by AL02528306 on 8/6/25.
//
import StoreKit
import SwiftUI

struct BottomPanelView: View {
    @ObservedObject var viewModel: StoreViewModel
    @State private var showAlert = false
    var body: some View {
        //MARK: - 모든 트랜잭션 리스트 뷰
        Divider()
            .background(.white)
        
        VStack(alignment: .leading, spacing: 12) {
            Text("History")
                .font(.headline)
                .foregroundColor(.white)
            
            ForEach(viewModel.historyTransactions, id: \.id) { tx in
                VStack(alignment: .leading, spacing: 4) {
                    Text("상품: \(tx.productID)")
                        .foregroundColor(.white)
                    Text("금액: \(String(describing: tx.price))")
                        .foregroundColor(.white)
                    
                    Text("구매일: \(tx.purchaseDate.formatted(.dateTime.month().day().hour().minute()))")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if tx.revocationDate != nil {
                        Text("환불됨")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.3))
                )
            }
        }
        
        Divider()
            .background(.white)
        
        VStack(alignment: .leading, spacing: 12) {
            if let data = viewModel.selectedTransaction?.jsonRepresentation,
               let jsonString = String(data: data, encoding: .utf8) {
                Text(jsonString)
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        
        Divider()
            .background(.white)
        
        ButtonCardView(title: "메일 전송") {
            let subject = "JSON Receipt"
            
            guard let data = viewModel.selectedTransaction?.jsonRepresentation,
                  let body = String(data: data, encoding: .utf8)?
                    .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                print("JSON 변환 실패 또는 트랜잭션 없음")
                return
            }
            
            let mailto = "mailto:?subject=\(subject)&body=\(body)"
            
            if let url = URL(string: mailto) {
                UIApplication.shared.open(url)
            } else {
                print("URL 생성 실패")
            }
        }
        
        ButtonCardView(title: "클립보드 복사") {
            guard let data = viewModel.selectedTransaction?.jsonRepresentation,
                  let body = String(data: data, encoding: .utf8)?
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                print("JSON 변환 실패 또는 트랜잭션 없음")
                return
            }
            print("클립보드 복사")
            
            UIPasteboard.general.string = body
            showAlert = true
        }
        .alert("Receipt Copied", isPresented: $showAlert) {
            Button("Confirm", role: .cancel) {}
        } message: {
            Text("영수증 정보가 클립보드에 복사되었습니다.")
        }
    }
}
