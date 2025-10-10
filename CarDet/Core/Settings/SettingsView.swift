//
//  SettingsView.swift
//  XcodeReleases
//
//  Created by BenjiLoya on 25.09.2025.
//


import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    
    @State private var askPermission: Bool = false
    
    var body: some View {
        
        let config = NotificationOnBoardingConfig(
            title: "Stay Connected with\nPush Notifications",
            content: "We will send you push notifications to keep you updated on the latest news and updates.",
            notificationTitle: "Hello benjiLoya!",
            notificationContent: "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
            primaryButtonTitle: "Continue",
            secondaryButtonTitle: "Ask Me Later"
        )
        
        NavigationStack {
            List {
                Button {
                    onSignOutPressed()
                } label: {
                    Text("Sign out")
                }
                
                Button("Show Notification Onboarding") {
                    askPermission.toggle()
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $askPermission) {
            NotificationOnBoarding(config: config) {
                /// Your App Logo!
                Image(systemName: "applelogo")
                    .font(.title2)
                    .foregroundStyle(.background)
                    .frame(width: 40, height: 40)
                    .background(.primary)
                    .clipShape(.rect(cornerRadius: 12))
            } onPermissionChange: { isApproved in
                print(isApproved)
            } onPrimaryButtonTap: {
                askPermission = false
            } onSecondaryButtonTap: {
                askPermission = false
            }
        }
    }
    
    func onSignOutPressed() {
        // do some logic to sign user out of app!
        dismiss()
        
        Task {
            try? await Task.sleep(for: .seconds(1))
            appState.updateViewState(showTabBarView: false)
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
