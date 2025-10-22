//
//  HomeView.swift
//  XcodeReleases
//
//  Created by BenjiLoya on 25.09.2025.
//

import SwiftUI

// MARK: - UI (task + refreshable)
struct HomeView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showInfo = false
    @Namespace private var infoSpace
    
    
    var body: some View {
     //   NavigationStack {
            VStack {
                Text("Hello, World!")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Home")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Draw", systemImage: "pencil") {
                        
                    }
                    Button("Erase", systemImage: "eraser") {
                        
                    }
                }
                
           //     ToolbarSpacer(.fixed, placement: .topBarTrailing)
                ToolbarItem(placement: .topBarTrailing) {
                    Button("info", systemImage: "info") {
                        showInfo.toggle()
                    }
                }
          //      .matchedTransitionSource(id: "info", in: infoSpace)
                
//                ToolbarItem(placement: .bottomBar) {
//                    Button("New", systemImage: "plus") {
//                        
//                    }
//                }
            }
            .sheet(isPresented: $showInfo) {
                InfoView()
                    .presentationDetents([.medium, .large])
                    .navigationTransition(.zoom(sourceID: "info", in: infoSpace))
            }
            .background(Color.themeBG)
     //   }
        // первая загрузка
        .task {
//            await vm.load()
        }
        // pull-to-refresh
        .refreshable {
//            await vm.load()
        }
    }
}

// MARK: - Previews
#Preview {
    HomeView()
}

