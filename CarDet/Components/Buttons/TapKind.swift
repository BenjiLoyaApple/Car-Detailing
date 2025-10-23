//
//  TapKind.swift
//  MyTask-Demo
//
//  Created by BenjiLoya on 17.09.2025.
//

import SwiftUI

// Универсальный выбор типа взаимодействия
enum TapKind {
    case tap     // onTapGesture на iOS 26+, иначе fallback на press
    case press   // всегда .anyButton(.press)
}

// Универсальный модификатор: без isLoading, только стратегия и действие
private struct TapHandlerModifier: ViewModifier {
    let tapKind: TapKind
    let action: () -> Void

    func body(content: Content) -> some View {
        switch tapKind {
        case .tap:
            if #available(iOS 26.0, *) {
                content
                    .onTapGesture {
                    action()
                }
            } else {
                content
                    .anyButton(.press) {
                    action()
                }
            }
        case .press:
            content
                .anyButton(.press) {
                action()
            }
        }
    }
}

// Удобный шорткат для любого View
extension View {
    func tapHandler(_ kind: TapKind = .press, action: @escaping () -> Void) -> some View {
        self.modifier(TapHandlerModifier(tapKind: kind, action: action))
    }
}
