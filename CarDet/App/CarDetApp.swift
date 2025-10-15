//
//  CarDetApp.swift
//  CarDet
//
//  Created by BenjiLoya on 09.10.2025.
//

import SwiftUI

@main
struct CarDetApp: App {
//    // MARK: - App Storage
    @AppStorage("isFaceID") private var isFaceIDEnabled: Bool = false
    @State private var isFaceIDAuthenticated = false
    @State private var errorMessage: String?
    
    var body: some Scene {
        WindowGroup {
            Group {
//                if let errorMessage = errorMessage {
                    // Показываем ошибку, если не прошел Face ID
//                    CustomErrorView(
//                        title: "Error",
//                        imageName: "faceid",
//                        description: errorMessage
//                    )
                    
//                } else if isFaceIDAuthenticated || !isFaceIDEnabled {
                    // Основное приложение
                    RootToastView {
                //        RouterView { _ in
                            AppView()
              //          }
                    }
//                } else {
                    // Индикатор загрузки перед Face ID
//                    ProgressView("Authenticating...")
//                        .padding()
//                }
            }
            .onAppear {
                // Проверка Face ID при запуске приложения
        //        authenticateWithFaceID()
            }
        }
    }
//    // MARK: - Face ID Authentication
//    private func authenticateWithFaceID() {
//        FaceIDManager.authenticateIfNeeded(isFaceIDEnabled: isFaceIDEnabled) { success, errorMessage in
//            if success {
//                isFaceIDAuthenticated = true
//            } else {
//                self.errorMessage = errorMessage
//            }
//        }
//    }
}
