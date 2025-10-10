//
//  CustomAppButton.swift
//  Components
//
//  Created by Benji Loya on 12.02.2025.
//

import SwiftUI

struct UniversalButton: View {
    var text: String?
    var systemIcon: String? = nil
    var font: Font = .body
    var fontWeight: Font.Weight = .semibold
    var foregroundColor: Color = .white
    var backgroundColor: Color = .blue
    var cornerRadius: CGFloat = 12
    var height: CGFloat = 50
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var style: ButtonStyleOption = .plain
    var action: () -> Void

    @State private var animateSymbol: Bool = false

    var body: some View {
        content
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(cornerRadius)
            .opacity(isDisabled ? 0.6 : 1.0)
            .anyButton(style) {
                animateSymbol.toggle()
                action()
            }
            .disabled(isDisabled || isLoading)
    }

    @ViewBuilder
    private var content: some View {
        if isLoading {
            HStack(spacing: 8) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                Text("Loading...")
                    .font(font)
                    .fontWeight(fontWeight)
            }
        } else {
            HStack(spacing: 8) {
                if let systemIcon {
                    Image(systemName: systemIcon)
                        .font(font)
                        .fontWeight(fontWeight)
                        .symbolEffect(.bounce, options: .nonRepeating, value: animateSymbol)
                }
                if let text {
                    Text(text)
                        .font(font)
                        .fontWeight(fontWeight)
                }
            }
        }
    }
}

#Preview("Universal Button") {
    VStack(spacing: 16) {
        UniversalButton(
            text: "Submit",
            systemIcon: "paperplane.fill",
            font: .title3,
            foregroundColor: .white,
            backgroundColor: .green,
            cornerRadius: 16,
            height: 55,
            isLoading: false,
            isDisabled: false,
            style: .press,
            action: {
                print("Pressed")
            }
        )
        
        UniversalButton(
            text: "Save",
            systemIcon: "cloud.fill",
            font: .subheadline,
            foregroundColor: .white,
            backgroundColor: .blue,
            cornerRadius: 16,
            height: 55,
            isLoading: false,
            isDisabled: false,
            style: .plain,
            action: {
                print("Pressed")
            }
        )
        
    }
    .padding()
}
