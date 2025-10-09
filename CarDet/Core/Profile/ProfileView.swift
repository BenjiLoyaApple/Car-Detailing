//
//  ProfileView.swift
//  CarDet
//
//  Created by BenjiLoya on 09.10.2025.
//

import SwiftUI

struct ProfileView: View {
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            VStack {
                
            }
            .navigationTitle("Profile")
            .navigationSubtitle("Benji Loya")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("info", systemImage: "info") {
//                     showInfo.toggle()
                    }
                }
                
                ToolbarSpacer(.fixed, placement: .topBarTrailing)
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Settings", systemImage: "gear") {
                        showSettings.toggle()
                    }
                }
            //    .matchedTransitionSource(id: "info", in: infoSpace)
                
//                ToolbarItem(placement: .bottomBar) {
//                    Button("New", systemImage: "plus") {
//
//                    }
//                }
            }
            .fullScreenCover(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
}

#Preview {
    ProfileView()
}
