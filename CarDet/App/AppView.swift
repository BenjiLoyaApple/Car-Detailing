//
//  AppView.swift
//  MyTask-Demo
//
//  Created by BenjiLoya on 22.07.2025.
//

import SwiftUI

struct AppView: View {
    @State var appState: AppState = AppState()
    ///Theme
    //  @AppStorage("userTheme") private var userTheme: Theme = .systemDefault
    
    var body: some View {
        AppViewBuilder(
            showTabBar: appState.showTabBar,
            tabbarView: {
                ContentViewTab()
            },
            onboardingView: {
                OnBoardingView()
            }
        )
        //   .preferredColorScheme(userTheme.colorScheme)
        .environment(appState)
    }
}

#Preview("AppView - Tabbar") {
    AppView(appState: AppState(showTabBar: true))
}
#Preview("AppView - Onboarding") {
    AppView(appState: AppState(showTabBar: false))
}
