//
//  View+EXT.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 10/6/24.
//

import SwiftUI

extension View {
    
    func profileCardBG() -> some View {
        self
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.customCardBG)
                    .shadow(color: .black.opacity(0.08), radius: 5, x: 5, y: 5)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: -4, y: -4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.gray.opacity(1.0), style: StrokeStyle(lineWidth: 0.1, lineCap: .round, dash: [10, 0]))
                    )
            )
    }
    
    func callToActionButton() -> some View {
        self
            .font(.headline)
            .foregroundStyle(Color.theme.darkBlack)
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .background(Color.theme.buttonBG)
            .cornerRadius(16)
    }
    
    func badgeButton() -> some View {
        self
            .font(.caption)
            .bold()
            .foregroundStyle(Color.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color.blue)
            .cornerRadius(6)
    }
    
    func placeholder(_ condition: Bool) -> some View {
        self.redacted(reason: condition ? .placeholder : [])
    }
}
