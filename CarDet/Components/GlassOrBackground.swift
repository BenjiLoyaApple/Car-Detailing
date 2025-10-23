//
//  GlassBackground26.swift
//  MyTask-Demo
//
//  Created by BenjiLoya on 22.09.2025.
//

import SwiftUI

struct GlassOrBackground: ViewModifier {
    let cornerRadius: CGFloat
    let fillColor: Color
    let strokeColor: Color
    let isInteractive: Bool

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            let stroked = content.overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(strokeColor, style: StrokeStyle(lineWidth: 0.5,
                                                            lineCap: .round,
                                                            dash: [10, 0]))
            )

            if isInteractive {
                stroked.glassEffect(
                    .clear.tint(fillColor).interactive(),
                    in: .rect(cornerRadius: cornerRadius)
                )
            } else {
                stroked.glassEffect(
                    .clear.tint(fillColor),
                    in: .rect(cornerRadius: cornerRadius)
                )
            }
        } else {
            content.background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(fillColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(strokeColor, style: StrokeStyle(lineWidth: 0.5,
                                                                    lineCap: .round,
                                                                    dash: [10, 0]))
                    )
            )
        }
    }
}

// хелпер
extension View {
    func glassOrBackground(
        cornerRadius: CGFloat,
        fillColor: Color,
        strokeColor: Color,
        isInteractive: Bool = true
    ) -> some View {
        self.modifier(GlassOrBackground(
            cornerRadius: cornerRadius,
            fillColor: fillColor,
            strokeColor: strokeColor,
            isInteractive: isInteractive
        ))
    }
}
