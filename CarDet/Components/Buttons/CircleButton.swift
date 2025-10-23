//
//  CircleButton.swift
//  MyTask-Demo
//
//  Created by BenjiLoya on 24.09.2025.
//

import SwiftUI

/// Переиспользуемая кнопка с текстом и SF Symbol
public struct CircleButton: View {
    private let systemImageName: String?
    private let font: Font?
    private let action: () -> Void
    
    // MARK: - Init
    public init(
        systemImageName: String? = nil,
        font: Font = .headline,
        action: @escaping () -> Void
    ) {
        self.systemImageName = systemImageName
        self.font = font
        self.action = action
    }
    
    // MARK: - Body
    public var body: some View {
        content
            .modifier(BaseButtonStyle())
            .modifier(GlassOrStrokeStyle())
            .tapHandler(.tap) {
                action()
            }
    }
    
    // MARK: - Content
    @ViewBuilder
    private var content: some View {
            if let systemImageName = systemImageName {
                Image(systemName: systemImageName)
                    .font(font)
            }
    }
}

// MARK: - Reusable Modifiers
/// Базовые модификаторы, общие для обеих веток iOS
private struct BaseButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 40, height: 40)
    }
}

/// Визуальное оформление: iOS 26+ — glassEffect, иначе — stroke + тени.
/// Тени оставлены близкими к исходным (легкие различия между ветками).
private struct GlassOrStrokeStyle: ViewModifier {
    
    func body(content: Content) -> some View {
        Group {
            if #available(iOS 26.0, *) {
                content
                    .glassEffect(.regular.interactive())
                    .contentShape(.circle)
            } else {
                content
                    .contentShape(.circle)
                    .shadow(color: .black.opacity(0.06), radius: 5, x: 3, y: 3)
                    .shadow(color: .black.opacity(0.03), radius: 5, x: -2, y: -2)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(.gray.opacity(0.2), lineWidth: 0.5)
                    )
            }
        }
    }
}

#Preview {
    VStack(spacing: 25) {
        CircleButton(
            systemImageName: "line.3.horizontal"
        ) { }
        CircleButton(
            systemImageName: "chevron.left"
        ) { }
        CircleButton(
            systemImageName: "phone"
        ) { }
        CircleButton(
            systemImageName: "info", font: .title3
        ) { }
    }
}
