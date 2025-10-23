//
//  SavingOverlay.swift
//  TaskManager
//
//  Created by Benji Loya on 16.05.2025.
//

import SwiftUI

struct SavingOverlay: View {
    var title: String = "Saving..."
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.darkBlack.opacity(0.7))
                .blur(radius: 10)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                    .scaleEffect(1.4)

                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.theme.darkBlack)
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.theme.darkWhite)
                    .shadow(radius: 10)
            )
            .frame(maxWidth: 240)
        }
    }
}


#Preview {
    SavingOverlay()
}
