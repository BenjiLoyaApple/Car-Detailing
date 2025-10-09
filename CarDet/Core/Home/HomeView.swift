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
    @State private var showSettings = false
    @Namespace private var infoSpace
    
    @State private var vm: XcodeViewModel
    
    init(dataService: DataServiceProtocol = ProductionDataService()) {
        _vm = State(initialValue: XcodeViewModel(dataService: dataService))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if let err = vm.errorText {
                    VStack(spacing: 12) {
                        Text("Ошибка: \(err)")
                            .foregroundColor(.red)
                        Button("Повторить") {
                            Task { await vm.load() }
                        }
                    }
                } else if vm.isLoading && vm.releases.isEmpty {
                    ProgressView("Загрузка…")
                } else {
                    List {
                        ForEach(vm.releases, id: \.id) { rel in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(rel.displayVersion)
                                    .font(.headline)
                                if let d = rel.displayDate {
                                    Text(d.formatted(date: .abbreviated, time: .omitted))
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                if !rel.architectures.isEmpty {
                                    Text("Arch: \(rel.architectures.joined(separator: ", "))")
                                        .font(.footnote)
                                }
                                if let url = rel.downloadURL {
                                    Link("Скачать", destination: url)
                                        .font(.footnote.weight(.semibold))
                                }
                            }
                            .padding(.vertical, 4)
                            .onAppear {
                                vm.loadMoreIfNeeded(currentItem: rel)
                            }
                        }
                        
                        if vm.isLoadingMore {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        }
                    }
                    .animation(.default, value: vm.releases.count)
                }
            }
            .navigationTitle("Xcode")
            .navigationSubtitle("Releases")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Help", systemImage: "questionmark") {
                        showSettings.toggle()
                    }
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Draw", systemImage: "pencil") {
                        
                    }
                    Button("Erase", systemImage: "eraser") {
                        
                    }
                }
                
                ToolbarSpacer(.fixed, placement: .topBarTrailing)
                ToolbarItem(placement: .topBarTrailing) {
                    Button("info", systemImage: "info") {
                        showInfo.toggle()
                    }
                }
                .matchedTransitionSource(id: "info", in: infoSpace)
                
                ToolbarItem(placement: .bottomBar) {
                    Button("New", systemImage: "plus") {
                        
                    }
                }
            }
            .sheet(isPresented: $showInfo) {
                InfoView()
                    .presentationDetents([.medium, .large])
                    .navigationTransition(.zoom(sourceID: "info", in: infoSpace))
            }
            .fullScreenCover(isPresented: $showSettings) {
                SettingsView()
            }
        }
        // первая загрузка
        .task {
            await vm.load()
        }
        // pull-to-refresh
        .refreshable {
            await vm.load()
        }
    }
}

// MARK: - Previews
#Preview {
    HomeView(dataService: MockDataService())
}

