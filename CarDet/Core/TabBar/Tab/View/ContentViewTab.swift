//
//  ContentView.swift
//  FloatTabBar
//
//  Created by Benji Loya on 20.08.2024.
//

import SwiftUI

struct ContentViewTab: View {
    /// View Properties
    @State private var activeTab: TabModel = .home
    @State private var isTabBarHidden: Bool = false
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                TabView(selection: $activeTab) {
                    HomeView()
                        .tag(TabModel.home)
                        .background {
                            if !isTabBarHidden {
                                HideTabBar {
                                    isTabBarHidden = true
                                }
                            }
                        }
                    
                    ProfileView()
                        .tag(TabModel.profile)
                }
            }
            if keyboardHeight == 0 {
                CustomTabBar(activeTab: $activeTab)
                    .transition(.move(edge: .bottom))
            }
        }
        .onAppear {
            // Подписываемся на изменения клавиатуры
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notif in
                if let keyboardFrame = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    withAnimation {
                        keyboardHeight = keyboardFrame.height
                    }
                }
            }
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                withAnimation {
                    keyboardHeight = 0
                }
            }
        }
    }
}


struct HideTabBar: UIViewRepresentable {
    var result: () -> ()
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        
        DispatchQueue.main.async {
            if let tabController = view.tabController {
                tabController.tabBar.isHidden = true
                result()
            }
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

extension UIView {
    var tabController: UITabBarController? {
        if let controller = sequence(first: self, next: {
            $0.next
        }).first(where: { $0 is UITabBarController }) as? UITabBarController {
            return controller
        }
        return nil
    }
}


#Preview {
    ContentViewTab()
}
