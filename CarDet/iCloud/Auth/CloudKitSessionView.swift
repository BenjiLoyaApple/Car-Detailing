//
//  CloudKitSessionView.swift
//  iCloudDemo
//
//  Created by Benji Loya on 06.05.2025.
//

/*
import SwiftUI

struct CloudKitSessionView: View {
    @ObservedObject var session: CloudKitManager
    var onProfileCreated: () -> Void

    @State private var showAlert = false
    @State private var showCreateProfile = false

    var body: some View {
        VStack(spacing: 16) {
            // MARK: - Header
            VStack(spacing: 0) {
                Image(systemName: "exclamationmark.icloud")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.primary)
                    .padding(.bottom, 10)
                
                Text("CloudKit Setup")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("We need access to iCloud and your basic info to personalize your experience.")
                    .font(.system(size: 12))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            .padding(.vertical, 40)

            // MARK: - Status Cards
            VStack(spacing: 10) {
                infoCard(icon: "icloud", title: "iCloud Sign-in", value: session.isSignedIn ? "Signed In" : "Not Signed In", color: session.isSignedIn ? .green : .red)

                infoCard(icon: "lock.icloud", title: "Permission", value: session.hasPermission ? "Granted" : "Not Granted", color: session.hasPermission ? .green : .orange)

                infoCard(icon: "person", title: "User Name", value: session.userName.isEmpty ? "—" : session.userName, color: .primary)
            }

            // MARK: - Request Access
            if !session.hasPermission {
                Button {
                    session.requestPermissionManually()
                } label: {
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.title)
                        .foregroundColor(.primary)
                }
                
//                CustomAppButton(
//                    imageSource: .systemName("person.crop.circle.badge.questionmark"),
//                    text: "Request iCloud Access",
//                    font: .subheadline,
//                    fontWeight: .semibold,
//                    foregroundColor: Color.theme.darkBlack,
//                    backgroundColor: Color.theme.darkWhite,
//                    height: 48,
//                    onButtonPressed: {
//                        session.requestPermissionManually()
//                    }
//                )
                .padding(.vertical)
            }
               

            // MARK: - Errors
            if !session.error.isEmpty {
                Text("⚠️ \(session.error)")
                    .foregroundColor(.red)
                    .font(.system(size: 10))
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }

            if !session.isReady {
                ProgressView("Loading...")
                    .padding(.top, 10)
            }

            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.15))
        .edgesIgnoringSafeArea(.bottom)
        .alert("iCloud Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(session.error)
        }
        .onChange(of: session.error) { _, error in
            showAlert = !error.isEmpty
        }
        .onAppear {
            if session.shouldPromptCreateProfile && session.hasPermission {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showCreateProfile = true
                }
            }
        }
        .onChange(of: session.shouldPromptCreateProfile) { _, newValue in
            if newValue && session.hasPermission {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    showCreateProfile = true
                }
            }
        }
//        .sheet(isPresented: $showCreateProfile) {
//            CreateProfileView(userName: session.userName) {
//                session.loadUserProfile()
//                onProfileCreated()
//            }
//            .presentationDetents([.height(500)])
//            .presentationCornerRadius(20)
//            .interactiveDismissDisabled(true)
//        }
    }

    // MARK: - Reusable Info Card
    @ViewBuilder
    func infoCard(icon: String, title: String, value: String, color: Color) -> some View {
        HStack {
            Label(title, systemImage: icon)
            
            Spacer()
            
            Text(value)
                .foregroundColor(color)
                .fontWeight(.medium)
        }
        .font(.subheadline)
        .padding(.vertical, 15)
        .padding(.horizontal)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}


#Preview {
    CloudKitSessionView(
        session: MockCloudKitSessionManager(),
        onProfileCreated: {
            print("✅ Mock: Profile created in preview")
        }
    )
}
*/
