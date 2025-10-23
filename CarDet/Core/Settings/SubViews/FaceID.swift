//
//  FaceID.swift
//  NewForSwiftUI
//
//  Created by Benji Loya on 08/03/2023.
//

import SwiftUI
import SwiftfulRouting

// MARK: - Face ID
struct FaceIdView: View {
    @Environment(\.router) var router
    
    @AppStorage("isFaceID") private var isFaceIDEnabled: Bool = false
    
    @State private var text: String = ""
    
    var body: some View {
        VStack {
            HeaderComponent(
                backButtonPressed: {
                    router.dismissScreen()
                },
                buttonImageName: "chevron.left") {
                Text("Face ID")
                    .font(.subheadline.bold())
            }
            
            VStack(alignment: .leading, spacing: 0) {
                
                Text("Enable Face ID to secure your app or ensure privacy when accessing certain features.")
                    .font(.footnote)
                    .foregroundStyle(.gray)
                    .padding(.bottom)
                    .padding(.top, 4)
                
                Toggle("Face ID", isOn: $isFaceIDEnabled)
                    .onChange(of: isFaceIDEnabled) { _, _ in
                        updateText()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            FaceIDManager.authenticateIfNeeded(isFaceIDEnabled: isFaceIDEnabled) { success, errorMessage in
                                if success {
                                    text = "Face ID authentication succeeded."
                                } else {
                                    text = errorMessage ?? "Face ID authentication failed."
                                }
                            }
                        }
                    }
                
                Text(text)
                    .font(.footnote)
                    .foregroundStyle(.gray.opacity(0.8))
                    .padding(.top, 2)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            Spacer()
        }
        .onAppear {
            updateText()
        }
        .navigationBarBackButtonHidden()
        .background(Color.theme.themeBG)
    }
    
    private func updateText() {
        text = "Face ID is \(isFaceIDEnabled ? "enabled" : "disabled")"
    }
}

#Preview {
    FaceIdView()
}
