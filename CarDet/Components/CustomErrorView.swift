//
//  CustomErrorView.swift
//  Components
//
//  Created by Benji Loya on 10.12.2024.
//

import SwiftUI

public struct CustomErrorView: View {
    private let title: String?
    private let imageName: String?
    private let description: String?
    
    // MARK: - Инициализация
    public init(
        title: String? = "Error",
        imageName: String? = "exclamationmark.triangle",
        description: String? = "Something went wrong. Please try again."
    ) {
        self.title = title
        self.imageName = imageName
        self.description = description
    }
    
    public var body: some View {
        VStack {
            ContentUnavailableView(
                "\(title ?? "Error")",
                systemImage: "\(imageName ?? "exclamationmark.triangle")",
                description: Text(description ?? "Something went wrong. Please try again.")
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    CustomErrorView()
}

