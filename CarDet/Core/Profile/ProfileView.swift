//
//  ProfileView.swift
//  CarDet
//
//  Created by BenjiLoya on 09.10.2025.
//

//import SwiftUI
//
//struct ProfileView: View {
//    @State private var showSettings = false
//    
//    var body: some View {
//        NavigationStack {
//            VStack {
//                
//            }
//            .navigationTitle("Profile")
//            .navigationSubtitle("Benji Loya")
//            .toolbar {
//                ToolbarItem(placement: .topBarLeading) {
//                    Button("info", systemImage: "info") {
////                     showInfo.toggle()
//                    }
//                }
//                
//                ToolbarSpacer(.fixed, placement: .topBarTrailing)
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button("Settings", systemImage: "gear") {
//                        showSettings.toggle()
//                    }
//                }
//            //    .matchedTransitionSource(id: "info", in: infoSpace)
//                
////                ToolbarItem(placement: .bottomBar) {
////                    Button("New", systemImage: "plus") {
////
////                    }
////                }
//            }
//            .fullScreenCover(isPresented: $showSettings) {
//                SettingsView()
//            }
//        }
//    }
//}
//
//#Preview {
//    ProfileView()
//}


import SwiftUI

struct ProfileView: View {

    @State private var user: UserModel = .mock
    @State private var avatarData: Data? = nil
    @State private var isLoading: Bool = true

//    @StateObject private var taskStore = TaskStore<TaskModel>(loader: {
//        try? await Task.sleep(for: .seconds(2))
//        return TaskModel.mocks
//    })
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ProfileSubview(
                    user: $user,
                    avatarData: $avatarData,
                    isLoading: $isLoading,
                    size: geo.size,
                    safeArea: geo.safeAreaInsets
                )
                .background(Color.themeBG)
                .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    ProfileView()
}

//MARK: - Profile Subview
struct ProfileSubview: View {

    @Binding var user: UserModel
    @Binding var avatarData: Data?
    @Binding var isLoading: Bool

    var size: CGSize
    var safeArea: EdgeInsets

    /// пропсы для аналитики
    //   let tasks: [TaskModel]
    //   let tasksIsLoading: Bool
    
    @State private var scrollProgress: CGFloat = 0
    @State private var textHeaderOffset: CGFloat = 0
    
    // NEW: флаг для навигации к SettingsView
    @State private var goToSettings: Bool = false

    var body: some View {
        let isHavingNotch = safeArea.bottom != 0

        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 12) {
                // Аватар
//                AvatarView(
//                    imageURL: user.userImage,
//                    imageData: $avatarData,
//                    fullName: user.fullName,
//                    width: 120, height: 120,
//                    shape: .circle,
//                    showBorder: false,
//                    isEditable: false
//                )
                
                Circle()
                
                .frame(width: 120 - (75 * scrollProgress), height: 120 - (75 * scrollProgress))
                .opacity(1 - scrollProgress)
                .blur(radius: scrollProgress * 10, opaque: true)
                .clipShape(Circle())
                .anchorPreference(key: AnchorKey.self, value: .bounds) { ["HEADER": $0] }
                .padding(.top, safeArea.top + 15)
                .offsetExtractor(coordinateSpace: "SCROLLVIEW") { rect in
                    guard isHavingNotch else { return }
                    let progress = -rect.minY / 25
                    scrollProgress = min(max(progress, 0), 1)
                }

                let fixedTop: CGFloat = safeArea.top - 2
                Text(user.fullName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.vertical, 15)
                    .background {
                        Rectangle()
                            .fill(Color.themeBG)
                            .frame(width: size.width)
                            .padding(.top, textHeaderOffset < fixedTop ? -safeArea.top : 0)
                            .shadow(color: .black.opacity(textHeaderOffset < fixedTop ? 0.1 : 0), radius: 5, x: 0, y: 5)
                    }
                    .offset(y: textHeaderOffset < fixedTop ? -(textHeaderOffset - fixedTop) : 0)
                    .offsetExtractor(coordinateSpace: "SCROLLVIEW") { textHeaderOffset = $0.minY }
                    .zIndex(1000)

                VStack(spacing: 14) {
                    /// Информация о юзере
                    ContactInfoCard(
                        email: user.emailAddress,
                        phone: user.phoneNumber,
                        city: user.city
                    )
                    .anyButton(.press) {
                        // openEditContacts()
                    }
                    
                    /// ✅ Аналитика заказов пользователя
                    MonthlyAnalyticsView(isLoading: isLoading) { month in
                        OrderAnalytics.countsByStatus(
                            orders: OrderModel.orders(forUser: user.userId),
                            in: month,
                            scope: .ownerOnly(user.userId)
                        )
                    }
                    
                    // Actions (пример — плоские пропсы внутрь)
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12),
                                        GridItem(.flexible(), spacing: 12)], spacing: 12) {
//                        ActionTile(icon: "star", title: "Get Help")
//                            .anyButton(.press) {
//                                router.showScreen(.push) { _ in
//                                    EmptyView()
//                                }
//                            }
//                        ActionTile(icon: "person.crop.circle.badge.plus", title: "Refer a Friend")
//                            .anyButton(.press) {
//                                router.showScreen(.push) { _ in
//                                    EmptyView()
//                                }
//                            }
                    }
                }
                .padding(.horizontal, 15)
                .padding(.bottom, 100)
            }
        }
        .skeleton(isRedacted: isLoading)
        .allowsHitTesting(!isLoading)
        .backgroundPreferenceValue(AnchorKey.self, { pref in
            GeometryReader { proxy in
                if let anchor = pref["HEADER"], isHavingNotch {
                    let frameRect = proxy[anchor]
                    let isHavingDynamicIsland = safeArea.top > 51
                    let capsuleHeight = isHavingDynamicIsland ? 37 : (safeArea.top - 15)
                    
                    Canvas { out, size in
                        out.addFilter(.alphaThreshold(min: 0.5))
                        out.addFilter(.blur(radius: 12))
                        
                        out.drawLayer { ctx in
                            if let headerView = out.resolveSymbol(id: 0) {
                                ctx.draw(headerView, in: frameRect)
                            }
                            
                            if let dynamicIsland = out.resolveSymbol(id: 1) {
                                /// Placing Dynamic Island
                                /// For more about Dynamic Island, Check out My Animation Videos about Dynamic Island
                                let rect = CGRect(x: (size.width - 120) / 2, y: isHavingDynamicIsland ? 11 : 0, width: 120, height: capsuleHeight)
                                ctx.draw(dynamicIsland, in: rect)
                            }
                        }
                    } symbols: {
                        HeaderView(frameRect)
                            .tag(0)
                            .id(0)
                        
                        DynamicIslandCapsule(capsuleHeight)
                            .tag(1)
                            .id(1)
                    }
                }
            }
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(Color.themeBG)
                    .frame(height: 15)
            }
        })
        .overlay(alignment: .top, content: {
            HStack {
                Spacer()
                
                CircleButton(
                    systemImageName: "line.3.horizontal"
                ) {
                    openSettings()
                }
            }
            .padding(15)
            .padding(.top, safeArea.top)
            .offset(y: -10)
        })
        .navigationDestination(isPresented: $goToSettings) {
            SettingsView()
                .navigationBarBackButtonHidden()
        }
        .coordinateSpace(name: "SCROLLVIEW")
        .task {
            await loadData()
        }
    }
    

    // MARK: - Route helpers
    private func openSettings() {
        goToSettings = true
    }
    
    //MARK: - Load Data
    private func loadData() async {
        try? await Task.sleep(for: .seconds(2))
        isLoading = false
    }
    
    // MARK: - Canvas Symbols
    @ViewBuilder
    private func HeaderView(_ frameRect: CGRect) -> some View {
        Circle()
            .fill(.black)
            .frame(width: frameRect.width, height: frameRect.height)
    }
    
    @ViewBuilder
    private func DynamicIslandCapsule(_ height: CGFloat = 37) -> some View {
        Capsule()
            .fill(.black)
            .frame(width: 120, height: height)
    }
}

