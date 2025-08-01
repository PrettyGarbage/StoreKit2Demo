//
//  ContentView.swift
//  StoreKit2TestApp
//
//  Created by AL02528306 on 8/1/25.
//

import SwiftUI
import StoreKit

struct ContentView: View {
    @State private var useStoreKit2 = true
    @State private var products: [Product] = []
    @State private var selectedProduct: Product?
    
    @State private var isProductFetchOn = true
    @State private var isPurchaseOn = true
    @State private var isCompletionOn = true
    
    init() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor.black
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.opacity(1)
                    .ignoresSafeArea() //safe area 까지
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        
                        StoreKitPanelView(useStoreKit2: $useStoreKit2, selectedProduct: $selectedProduct)
                        
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        RequestPanelView(isProductFetchOn: $isProductFetchOn, isPurchaseOn: $isPurchaseOn, isCompletionOn: $isCompletionOn)
                    }
                }
            }
            .navigationTitle("StoreKit Test App")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}
