//
//  ContentView.swift
//  StoreKit2TestApp
//
//  Created by AL02528306 on 8/1/25.
//

import SwiftUI
import StoreKit

struct ContentView: View {
    @StateObject private var storeKitViewModel = StoreViewModel()
    
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
                        StoreKitPanelView(viewModel: storeKitViewModel)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        RequestPanelView(viewModel: storeKitViewModel)
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        ActionPanelView(viewModel: storeKitViewModel)
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        BottomPanelView(viewModel: storeKitViewModel)
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
