//
//  CustomTabBar.swift
//  FloatTabBar
//
//  Created by Benji Loya on 20.08.2024.
//

import SwiftUI

struct CustomTabBar: View {
    
    var activeForeground: Color = .theme.darkBlack
    var activeBackground: Color = .primary
    @Binding var activeTab: TabModel
    /// MatchedGeometry Effect
    @Namespace private var animation
    @Namespace private var createAnimation
    /// View Properties
    @State private var tabLocation: CGRect = .zero
    
    @State private var showCreateView = false
    var body: some View {
        let status = activeTab == .home //|| activeTab == .schedule
        
        HStack(spacing: !status ? 0 : 22) {
            HStack(spacing: 0) {
                ForEach(TabModel.allCases, id: \.rawValue) { tab in
                    Button {
                        activeTab = tab
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: tab.rawValue)
                                .font(.title3)
                                .frame(width: 30, height: 30)
                            
                            if activeTab == tab {
                                Text(tab.title)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                            }
                        }
                        .foregroundStyle(activeTab == tab ? activeForeground : .gray)
                        .padding(.vertical, 3)
                        .padding(.leading, 10)
                        .padding(.trailing, 15)
                        .contentShape(.rect)
                        .background {
                            if activeTab == tab {
                                Capsule()
                                    .fill(.clear)
                                    .fill(activeBackground.gradient)
                                    .onGeometryChange(for: CGRect.self, of: {
                                        $0.frame(in: .named("TABBARVIEW"))
                                    }, action: { newValue in
                                        tabLocation = newValue
                                    })
                                    .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(alignment: .leading) {
                Capsule()
                    .fill(activeBackground.gradient)
                    .frame(width: tabLocation.width, height: tabLocation.height)
                    .offset(x: tabLocation.minX)
                
            }
            .coordinateSpace(.named("TABBARVIEW"))
            .padding(.horizontal, 5)
            .frame(height: 46)
            // iOS 26+: стеклянный эффект
            .modifier(GlassFallbackCapsule())
            .zIndex(10)
            
                Image(systemName: "plus")
                    .font(.title3)
                    .frame(width: 44, height: 44)
                    .foregroundColor(.primary)
                    .background(Color.black.opacity(0.001))
                    .matchedTransitionSource(id: "create", in: createAnimation)
                    .clipShape(Circle())
                    .glassEffect(.regular.interactive(status))
                    .shadow(color: .black.opacity(0.08), radius: 4, x: 3, y: 3)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: -2, y: -2)
                    .allowsHitTesting(status)
                    .opacity(status ? 1.0 : 0)
                    .offset(x: status ? 0 : -20)
                    .padding(.leading, status ? 0 : -44)
                    .onTapGesture {
                        showCreateView.toggle()
//                        router.showScreen(.fullScreenCover) { _ in
//                            CreateTaskView()
//                                .navigationBarBackButtonHidden()
//                        }
                    }
        }
        .animation(.smooth(duration: 0.3, extraBounce: 0), value: activeTab)
        .sheet(isPresented: $showCreateView) {
            CreateView()
                .presentationDetents([.medium, .large])
                .navigationTransition(.zoom(sourceID: "create", in: createAnimation))
        }
    }
}

//#Preview {
//    CustomTabBar(activeTab: .constant(.timeline))
//}

#Preview {
    ContentViewTab()
}

// MARK: - Local fallback modifier for glass effect on capsule
private struct GlassFallbackCapsule: ViewModifier {
    func body(content: Content) -> some View {
        Group {
            if #available(iOS 26.0, *) {
                content
                    .glassEffect(.regular)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
                    .shadow(color: .black.opacity(0.08), radius: 4, x: -4, y: -4)
            } else {
                content
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(
                        Capsule()
                            .strokeBorder(.white.opacity(0.08), lineWidth: 0.5)
                    )
            }
        }
    }
}
