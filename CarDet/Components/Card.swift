//
//  Card.swift
//  MyTask-Demo
//
//  Created by BenjiLoya on 13.08.2025.
//

import SwiftUI

struct Card<Content: View>: View {
    var spacing: CGFloat = 12
    var padding: CGFloat = 14
    var cornerRadius: CGFloat = 16
    var strokeOpacity: CGFloat = 1.0
    var fill: Color = .customCardBG
    var strokeBG: Color = .gray
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            content
        }
        .padding(padding)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(fill)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
                .shadow(color: .black.opacity(0.03), radius: 5, x: -4, y: -4)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(strokeBG.opacity(strokeOpacity), style: StrokeStyle(lineWidth: 0.1, lineCap: .round, dash: [10, 0]))
                )
        )
    }
}

struct CardHeader<Trailing: View>: View {
    var icon: String
    var title: String
    @ViewBuilder var trailing: () -> Trailing

    init(icon: String, title: String, @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }) {
        self.icon = icon
        self.title = title
        self.trailing = trailing
    }

    var body: some View {
        HStack(spacing: 15) {
            Label(title, systemImage: icon)
                .font(.system(size: 16, weight: .semibold))
            
            Spacer(minLength: 0)
            
            trailing()
        }
    }
}

#Preview("AboutCard – long & collapsible") {
    ContactInfoCard(
        email: UserModel.mock.emailAddress,
        phone: UserModel.mock.phoneNumber,
        city: UserModel.mock.city,
    )
    .padding()
}




struct InfoRow: View {
    var icon: String
    var title: String
    var value: String
    var valueColor: Color = .secondary

    init(icon: String, title: String, value: String, valueColor: Color = .secondary) {
        self.icon = icon
        self.title = title
        self.value = value
        self.valueColor = valueColor
    }

    var body: some View {
        HStack(spacing: 12) {
            Label(title, systemImage: icon)
                .font(.system(size: 14, weight: .regular))

            Spacer(minLength: 8)

            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(valueColor)
                .frame(maxWidth: .infinity, alignment: .trailing)

        }
    }
}
