//
//  SettingsView.swift
//  XcodeReleases
//
//  Created by BenjiLoya on 25.09.2025.
//

import SwiftUI
import SwiftfulRouting

struct SettingsView: View {
    @Environment(\.router) var router
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var scheme
    @AppStorage("userTheme") private var userTheme: Theme = .systemDefault
    
    @State private var askPermission: Bool = false
    @State private var changeTheme: Bool = false
    @Namespace private var themeSpace
    
    @State private var showDeleteAlert = false

    var body: some View {
        
        let config = NotificationOnBoardingConfig(
            title: "Stay Connected with\nPush Notifications",
            content: "We will send you push notifications to keep you updated on the latest news and updates.",
            notificationTitle: "Hello benjiLoya!",
            notificationContent: "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
            primaryButtonTitle: "Continue",
            secondaryButtonTitle: "Ask Me Later"
        )
        
        VStack(spacing: 0) {
            HeaderComponent(
                backButtonPressed: {
                  //  dismiss()
                    router.dismissScreen()
                },
                buttonImageName: "xmark"
            ) {
                Text("Settings and activity")
                    .font(.subheadline.bold())
            }

            ScrollView(.vertical) {
                VStack(spacing: 10) {
                    appAndMediaSection()
                    DividerView()
#if DEBUG
                    howToUseSection()
                    DividerView()
                    supportSection()
                    DividerView()
#endif
                    loginSection()
                }
                .padding(.top, 10)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color.theme.themeBG)
        .preferredColorScheme(userTheme.colorScheme)
        .sheet(isPresented: $changeTheme) {
            ThemeChangeView(scheme: scheme)
                .presentationDetents([.height(410)])
                .presentationBackground(.clear)
//                .presentationDetents([.medium, .large])
                .navigationTransition(.zoom(sourceID: "theme", in: themeSpace))
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
        .alert("Delete Account?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}

            Button("Delete", role: .destructive) {
                HapticManager.instance.notification(type: .success) // или .warning/.error по желанию
                onSignOutPressed()
            }
        } message: {
            Text("This action cannot be undone. Are you sure you want to delete your account?")
        }
    }

    // MARK: - Sections
    private func appAndMediaSection() -> some View {
        SectionView(title: "Your app and media") {
            SettingsButton(imageName: "bell", title: "Notifications", showTrailingIcon: false) {
                askPermission.toggle()
            }

            SettingsButton(imageName: "location.app", title: "Location") {
                print("Location tapped")
            }

            SettingsButton(imageName: "faceid", title: "Faсe ID") {
                router.showScreen(.push) { _ in FaceIdView() }
            }

            SettingsButton(imageName: "person.and.background.dotted", title: "Photos Access") {
              //  router.pushScreen(.photoPermission)
            }

            SettingsButton(imageName: "info.circle", title: "Device info") {
             //   router.pushScreen(.deviceInfo)
            }

            SettingsButton(imageName: "moon", title: "Theme", showTrailingIcon: false) {
                changeTheme.toggle()
            }
            .matchedTransitionSource(id: "theme", in: themeSpace)
        }
    }

    private func howToUseSection() -> some View {
        SectionView(title: "How to use Tasker App") {
            SettingsButton(imageName: "bookmark", title: "Saved") {
             //   router.pushScreen(.saved)
            }

            SettingsButton(imageName: "clock.arrow.trianglehead.counterclockwise.rotate.90", title: "Archive") {
                print("Archive tapped")
            }

            SettingsButton(imageName: "chart.xyaxis.line", title: "Your activity") {
                print("Your activity tapped")
            }

            SettingsButton(imageName: "character.square", title: "Language") {
             //   router.pushScreen(.language)
            }

            SettingsButton(imageName: "clock", title: "Time management") {
                print("Time management tapped")
            }
        }
    }

    private func supportSection() -> some View {
        SectionView(title: "More info and support") {
            SettingsButton(imageName: "questionmark.circle", title: "Help") {
                print("Help tapped")
            }

            SettingsButton(imageName: "exclamationmark.shield", title: "Privacy Center") {
                print("Privacy Center tapped")
            }

            SettingsButton(imageName: "person", title: "Account Status") {
                print("Account Status tapped")
            }

            SettingsButton(imageName: "info.circle", title: "About") {
                print("About tapped")
            }
        }
    }

    private func loginSection() -> some View {
        SectionView(title: "Login") {
            SettingsButton(title: "Log Out", showTrailingIcon: false) {
                onSignOutPressed()
            }

            SettingsButton(title: "Delete Account", showTrailingIcon: false) {
                HapticManager.instance.impact(style: .medium)
                showDeleteAlert = true
            }
        }
    }

    // MARK: - Sign Out
    private func onSignOutPressed() {
        router.dismissAllScreens()
        Task {
            appState.updateViewState(showTabBarView: false)
            try? await Task.sleep(for: .milliseconds(500))
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}

