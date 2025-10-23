//
//  SettingsOptions.swift
//  ArmMash
//
//  Created by Benji Loya on 14.01.2025.
//

import SwiftUI

// MARK: - SectionView Component
struct SectionView<Content: View>: View {
    let title: LocalizedStringKey
    let content: () -> Content

    init(title: LocalizedStringKey, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.footnote.bold())
                .foregroundColor(.gray)
                .padding(.leading, 12)

            content()
        }
        .padding(.bottom, 4)
    }
}

// MARK: - DividerView
struct DividerView: View {
    var body: some View {
        Rectangle()
            .frame(maxWidth: .infinity)
            .frame(height: 4)
            .foregroundStyle(.gray.opacity(0.1))
    }
}
