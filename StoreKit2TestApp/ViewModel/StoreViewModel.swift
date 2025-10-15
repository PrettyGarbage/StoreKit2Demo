//
//  StoreViewModel.swift
//  StoreKit2TestApp
//
//  Created by AL02528306 on 8/5/25.
//

import Foundation
import StoreKit
import SwiftUI
import DeclaredAgeRange

//MARK: - Main Thread에서만 접근 가능
@MainActor
class StoreViewModel: ObservableObject {
    @Published var useStoreKit2 = true
    @Published var products: [Product] = []
    @Published var selectedProductID: String? = nil
    var selectedProduct: Product? {
        products.first(where: { $0.id == selectedProductID })
    }
    
    @Published var isProductFetchOn = false
    @Published var isCompletionOn = false
    
    @Published var historyTransactions: [StoreKit.Transaction] = []
    @Published var uncompletedTransactions: [StoreKit.Transaction] = []
    @Published var selectedTransactionID: String? = nil
    var selectedTransaction: StoreKit.Transaction? {
        uncompletedTransactions.first(where: { $0.productID == selectedTransactionID })
    }
    
    private var updateTask: Task<Void, Never>? = nil
    
    //MARK: - String 배열 (상품 id 정보들) 상품 정보 가져오기 (Refresh)
    func fetchProducts(with ids: [String]) async {
        do {
            self.products = try await Product.products(for: ids)
            
            for product in products {
                print("상품 ID: \(product.id), 이름: \(product.displayName), 가격: \(product.displayPrice)")
            }
        } catch {
            print("상품 조회 실패: \(error)")
        }
    }
    
    //MARK: - 상품 구매 (Purchase)
    func purchaseSelectedProduct() async {
        guard let product = selectedProduct else {
            print("선택된 상품이 없습니다.")
            return
        }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verificationResult):
                switch verificationResult {
                case .verified(let transaction):
                    print("구매 완료! finish 처리전")
                    
                    //MARK: - Consume or Finish : 상품 지급후 소모
                    if(isCompletionOn) {
                        selectedProductID = nil
                        await transaction.finish()
                        print("구매 완료! finish 처리후")
                    }
                case .unverified(let transactionId, let productId):
                    print("구매 완료, 영수증 검증되지 않았습니다. transactionId: \(transactionId), productId: \(productId)")
                }
            case .userCancelled:
                print("User Canceled")
            case .pending:
                print("Pending Purchase")
            @unknown default:
                print("Unknown Purchase Result")
            }
        } catch {
            print("purchase 실패 : \(error.localizedDescription)")
        }
    }
    
    //MARK: - 구매 복원 (Restore)
    func restorePurchases() async {
        uncompletedTransactions.removeAll()
        
        do {
            for await result in Transaction.unfinished {
                let transaction = try result.payloadValue
                print("Restore Purchase: \(transaction.productID) , TransactionID: \(transaction.id)")
                uncompletedTransactions.append(transaction)
            }
        } catch {
            print("transaction restore 실패 : \(error.localizedDescription)")
        }
    }
    
    //MARK: - 트랜잭션 Finish 처리
    func finishTransaction() async {
        guard let selectedTransaction = uncompletedTransactions.first else { return }
        
        selectedTransactionID = nil
        await selectedTransaction.finish()
        
        print("Transaction Finished: \(selectedTransaction.productID)")
            
        await restorePurchases()
    }
    
    //MARK: - 히스토리 트랜잭션 불러오기
    func loadAllTransactions() async {
        historyTransactions.removeAll()
        
        var result: [StoreKit.Transaction] = []
        for await txResult in Transaction.all {
            do {
                let tx = try txResult.payloadValue
                result.append(tx)
            } catch {
                print("히스토리 로딩 실패: \(error)")
            }
        }

        // 최신 순 정렬
        DispatchQueue.main.async {
            self.historyTransactions = result.sorted { $0.purchaseDate > $1.purchaseDate }
        }
    }
    
    func listenForTransaction() {
        updateTask = Task.detached(priority: .background) {
            for await result in Transaction.updates {
                do {
                    let transaction = try result.payloadValue
                    if transaction.revocationDate == nil {
                        print("업데이트 감지 - \(transaction.productID)")
                    }
                } catch {
                    print("Transaction Update Failed: \(error)")
                }
            }
        }
    }
    
    //MARK: - 연령 요청
    func onRequestDeclaredAgeRange(presenter: UIViewController) async {
        do {
            // 게이트는 최소 2년 간격, 최대 3개
            let response = try await AgeRangeService.shared
                .requestAgeRange(ageGates: 5, 12, 18, in: presenter)
            
            switch response {
            case .sharing(let range):
                guard let lower = range.lowerBound else {
                    // < 최저 게이트 미만 (여기선 <5)
                    print("sharing : under \(5)")
                    return
                }
                if lower >= 18 {
                    print("sharing : 18+ Available")
                } else if lower >= 15 {
                    print("sharing : 15+ Available")
                } else if lower >= 13 {
                    print("sharing : 13+ Available")
                } else if lower >= 5 {
                    print("sharing : 5+ Available")
                }
                
            case .declinedSharing:
                print("declined sharing")
            @unknown default:
                print("unknown error")
            }
        } catch let e as AgeRangeService.Error {
            switch e {
            case .notAvailable:
                print("not available")
            case .invalidRequest:
                print("invalid request (check ageGates spacing/max count)")
            @unknown default:
                print("unknown AgeRangeService error: \(e)")
            }
        } catch {
            print("unexpected error: \(error.localizedDescription)")
        }
    }
    
    deinit{
        updateTask?.cancel()
    }
}
