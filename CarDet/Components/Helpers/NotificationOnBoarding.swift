//
//  NotificationOnBoarding.swift
//  NotificationPermission
//
//  Created by Balaji Venkatesh on 05/09/25.
//

import SwiftUI
import UserNotifications

struct NotificationOnBoardingConfig {
    var title: String
    var content: String
    /// Notification Properties
    var notificationTitle: String
    var notificationContent: String
    /// Other Properties
    var primaryButtonTitle: String
    var secondaryButtonTitle: String
}

struct NotificationOnBoarding<NotificationLogo: View>: View {
    var config: NotificationOnBoardingConfig
    @ViewBuilder var notificationLogo: NotificationLogo
    var onPermissionChange: (_ isApproved: Bool) -> ()
    var onPrimaryButtonTap: () -> ()
    var onSecondaryButtonTap: () -> ()
    /// View Properties
    @State private var animateNotification: Bool = false
    @State private var loopContinues: Bool = true
    @State private var askPermission: Bool = false
    @State private var showArrow: Bool = false
    @State private var authorization: UNAuthorizationStatus = .notDetermined
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openURL) private var openURL
    var body: some View {
        ZStack {
            ZStack {
                Rectangle()
                    .fill(backgroundColor)
                    .ignoresSafeArea()
                    .blurOpacity(askPermission)
                
                /// Allow Button Pointing Arrow
                Image(systemName: "arrow.up")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundStyle(foregroundColor)
                    /// Using Offset to adjust the arrow to point the allow button
                    /// iOS 26 have slightly different offset, since it's having larger button padding!
                    .offset(x: isiOS26 ? 75 : 70, y: 155)
                    .blurOpacity(showArrow)
            }
            .allowsHitTesting(false)
            
            /// Animated Mobile Like Notification UI
            VStack(spacing: 0) {
                iPhonePreview()
                    .padding(.top, 15)
                
                VStack(spacing: 20) {
                    Text(config.title)
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(config.content)
                        .font(.callout)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer(minLength: 0)
                    
                    /// Primary & Secondary Button's
                    Button {
                        if authorization == .authorized {
                            onPrimaryButtonTap()
                        } else if authorization == .denied {
                            /// Visit Settings
                            if let settingsURL = URL(string: UIApplication.openNotificationSettingsURLString) {
                                openURL(settingsURL)
                            }
                        } else {
                            askNotificationPermission()
                        }
                    } label: {
                        Text(authorization == .authorized ? "You're All Set!" : authorization == .denied ? "Go to Settings" : config.primaryButtonTitle)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(foregroundColor)
                            .frame(height: 55)
                            .background(backgroundColor, in: .rect(cornerRadius: 20))
                    }
                    .geometryGroup()
                    
                    if authorization == .notDetermined {
                        Button {
                            onSecondaryButtonTap()
                        } label: {
                            Text(config.secondaryButtonTitle)
                                .fontWeight(.semibold)
                                .foregroundStyle(backgroundColor)
                        }
                    }
                }
                .padding(.horizontal, 15)
                .padding(.bottom, 20)
            }
            .blurOpacity(!askPermission)
        }
        /// To Cut off the infinite loop!
        .onDisappear { loopContinues = false }
        .task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            let authorization = settings.authorizationStatus
            self.authorization = authorization
            
            if authorization == .authorized {
                onPermissionChange(true)
            }
            
            if authorization == .denied {
                onPermissionChange(false)
            }
        }
        .interactiveDismissDisabled()
    }
    
    @ViewBuilder
    private func iPhonePreview() -> some View {
        GeometryReader {
            let size = $0.size
            /// Scaling to fit the Preview for smaller devices
            /// You can increase the value 340 to more to have more scaling!
            let scale = min(size.height / 340, 1)
            let width: CGFloat = 320
            let cornerRadius: CGFloat = 30
            
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor.opacity(0.06))
                
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(.gray.opacity(0.5), lineWidth: 1.5)
                
                /// Mock Widgets & App's
                VStack(spacing: 15) {
                    HStack(spacing: 15) {
                        RoundedRectangle(cornerRadius: 20)
                        
                        RoundedRectangle(cornerRadius: 20)
                    }
                    .frame(height: 130)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(spacing: 15), count: 4), spacing: 15) {
                        ForEach(1...12, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 10)
                                .frame(height: 55)
                        }
                    }
                }
                .padding(20)
                .padding(.top, 20)
                .foregroundStyle(backgroundColor.opacity(0.1))
                
                /// Status Bar
                HStack(spacing: 4) {
                    Text("9:41")
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Image(systemName: "cellularbars")
                    
                    Image(systemName: "wifi")
                    
                    Image(systemName: "battery.50percent")
                }
                .font(.caption2)
                .padding(.horizontal, 20)
                .padding(.top, 15)
                
                /// Notification View
                NotificationView()
            }
            .frame(width: width)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            /// Gradient Mask
            .mask {
                LinearGradient(stops: [
                    .init(color: .white, location: 0),
                    .init(color: .clear, location: 0.9)
                ], startPoint: .top, endPoint: .bottom)
                /// For the visibility of the border!
                .padding(-1)
            }
            .scaleEffect(scale, anchor: .top)
        }
    }
    
    @ViewBuilder
    private func NotificationView() -> some View {
        HStack(alignment: .center, spacing: 8) {
            notificationLogo
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(config.notificationTitle)
                        .font(.callout)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Spacer(minLength: 0)
                    
                    Text("Now")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.gray)
                }
                
                Text(config.notificationContent)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.gray)
                    .lineLimit(2)
            }
        }
        .padding(12)
        .background(.background)
        .clipShape(.rect(cornerRadius: 20))
        .shadow(color: .gray.opacity(0.5), radius: 1.5)
        .padding(.horizontal, 12)
        .padding(.top, 40)
        .offset(y: animateNotification ? 0 : -200)
        .clipped()
        .task {
            await loopAnimation()
        }
    }
    
    private func loopAnimation() async {
        try? await Task.sleep(for: .seconds(0.5))
        
        withAnimation(.smooth(duration: 1)) {
            animateNotification = true
        }
        
        try? await Task.sleep(for: .seconds(4))
        
        withAnimation(.smooth(duration: 1)) {
            animateNotification = false
        }
        
        guard loopContinues else { return }
        try? await Task.sleep(for: .seconds(1.3))
        await loopAnimation()
    }
    
    private func askNotificationPermission() {
        Task { @MainActor in
            withAnimation(.smooth(duration: 0.3, extraBounce: 0)) {
                askPermission = true
            }
            
            try? await Task.sleep(for: .seconds(0.3))
            
            withAnimation(.linear(duration: 0.3)) {
                showArrow = true
            }
            
            /// Asking Notification Permission!
            let status = (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])) ?? false
            let authorization = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
            onPermissionChange(status)
            
            /// Removing dark background and arrow view!
            withAnimation(.smooth(duration: 0.3, extraBounce: 0)) {
                askPermission = false
                showArrow = false
                self.authorization = authorization
            }
        }
    }
    
    var backgroundColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var foregroundColor: Color {
        colorScheme != .dark ? .white : .black
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}

fileprivate extension View {
    @ViewBuilder
    func blurOpacity(_ status: Bool) -> some View {
        self
            .compositingGroup()
            .opacity(status ? 1 : 0)
            .blur(radius: status ? 0 : 10)
    }
    
    var isiOS26: Bool {
        if #available(iOS 26, *) {
            return true
        }
        
        return false
    }
}
