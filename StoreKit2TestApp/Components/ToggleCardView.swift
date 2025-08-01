//
//  ToggleCardView.swift
//  StoreKit2TestApp
//
//  Created by AL02528306 on 8/1/25.
//
import SwiftUI

struct ToggleCardView: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: $isOn) {
                Text(title)
                    .foregroundColor(.white)
            }
            .toggleStyle(SwitchToggleStyle(tint: .blue))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(1), lineWidth: 1)
                
        )
    }
}
