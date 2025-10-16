//
//  HeaderView.swift
//  Components
//
//  Created by Benji Loya on 04.12.2024.
//

import SwiftUI

public struct HeaderComponent<Content: View>: View {
    public var backButtonPressed: (() -> Void)? = nil
    public var buttonImageName: String? = nil
    public var font: Font
    public let content: Content
    
    public init(
        backButtonPressed: (() -> Void)? = nil,
        buttonImageName: String? = "chevron.left",
        font: Font = .title3,
        @ViewBuilder content: () -> Content
    ) {
        self.backButtonPressed = backButtonPressed
        self.buttonImageName = buttonImageName
        self.font = font
        self.content = content()
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                if let buttonImageName = buttonImageName, let action = backButtonPressed {
                    
                    CircleButton(
                        systemImageName: buttonImageName, font: font
                    ) {
                        action()
                    }
                }
                
                Spacer(minLength: 0)
                
                content
                    .offset(x: -25)
                
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 15)
            .padding(.bottom, 10)
            
            Divider()
                .opacity(0.6)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        HeaderComponent(
            backButtonPressed: { print("Back pressed") }
        ) {
            Text("Header with Icon")
        }
        
        HeaderComponent(
            backButtonPressed: { print("Back pressed") },
            buttonImageName: "xmark"
        ) {
            Text("Header with Close Icon")
        }
        
        HeaderComponent(buttonImageName: nil) {
            Text("Header without Button")
        }
    }
}
