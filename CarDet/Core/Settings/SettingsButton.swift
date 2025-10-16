//
//  SettingsButton.swift
//  MyThreads
//
//  Created by Benji Loya on 18.08.2024.
//

import SwiftUI

/// Кастомная кнопка с иконкой и текстом.
public struct SettingsButton: View {
    
    @State private var animateSymbol: Bool = false
    // MARK: - Параметры кнопки
    private let imageName: String?
    private let title: LocalizedStringKey?
    private let showTrailingIcon: Bool
    private let onButtonPressed: () -> Void
    
    // MARK: - Инициализация
    public init(
        imageName: String? = nil,
        title: LocalizedStringKey? = nil,
        showTrailingIcon: Bool = true,
        onButtonPressed: @escaping () -> Void = {}
    ) {
        self.imageName = imageName
        self.title = title
        self.showTrailingIcon = showTrailingIcon
        self.onButtonPressed = onButtonPressed
        
    }
    
    // MARK: - Тело кнопки
    public var body: some View {
        Button(action: {
                animateSymbol.toggle()
                onButtonPressed()
            }) {
            HStack(spacing: 15) {
                if let imageName = imageName {
                    Image(systemName: imageName)
                        .font(.system(size: 21))
                        .symbolEffect(.bounce, options: .nonRepeating, value: animateSymbol)
                }
                
                if let title = title {
                    Text(title)
                        .font(.system(size: 16))
                }
                
                Spacer(minLength: 0)
                
                if showTrailingIcon {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .fontWeight(.light)
                        .padding(.trailing, 10)
                        .foregroundStyle(.gray)
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(
                Color.black.opacity(0.001)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Превью
#Preview {
    VStack(spacing: 10) {
        
        SettingsButton(
            imageName: "moon",
            title: "Theme",
        ) {
            print("Theme button pressed")
        }
        
        SettingsButton(
            title: "Just Text Button",
        ) {
            print("Text button pressed")
        }
        
        SettingsButton(
            title: "Text",
            showTrailingIcon: false,
        ) {
            print("Text button pressed")
        }
        
    }
    .padding()
}

