//
//  ButtonCardView.swift
//  StoreKit2TestApp
//
//  Created by AL02528306 on 8/6/25.
//

import SwiftUI

struct ButtonCardView: View {
    var title: String
    var action: () -> Void
    
    @State private var isPressed: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0)) {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0)) {
                        isPressed = false
                    }
                }
                action()
            }, label: {
                HStack {
                    Spacer()
                    Text(title)
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                }
            })
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(1), lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
    }
}
