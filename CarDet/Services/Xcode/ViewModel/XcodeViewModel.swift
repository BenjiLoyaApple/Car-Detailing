//
//  XcodeViewModel.swift
//  XcodeReleases
//
//  Created by BenjiLoya on 25.09.2025.
//

import Foundation
import Observation

@MainActor
@Observable
final class XcodeViewModel {
    // Public, visible items for the UI
    var releases: [XcodeReleaseModel] = []
    var errorText: String?
    var isLoading = false
    var isLoadingMore = false
    
    // Private, full dataset for pagination
    private var allReleases: [XcodeReleaseModel] = []
    private let pageSize = 20
    
    private let dataService: DataServiceProtocol
    
    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
    }
    
    var hasMorePages: Bool {
        releases.count < allReleases.count
    }
    
    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorText = nil
        defer { isLoading = false }
        
        do {
            let items = try await dataService.getData()
            
            // Сортируем по дате (новые сверху)
            let sorted = items.sorted { lhs, rhs in
                let l = lhs.date
                let r = rhs.date
                return (l?.year ?? 0, l?.month ?? 0, l?.day ?? 0) >
                       (r?.year ?? 0, r?.month ?? 0, r?.day ?? 0)
            }
            
            // Удаляем дубли по id (оставляем первую встреченную запись)
            var seen = Set<String>()
            let unique = sorted.filter { seen.insert($0.id).inserted }
            
            // жёстко по sha1:
            /*
            var seenSha = Set<String>()
            let unique = sorted.filter { release in
                guard let sha = release.checksums?.sha1, !sha.isEmpty else { return true }
                return seenSha.insert(sha).inserted
            }
            */
            
            // Сохраняем весь датасет и первую страницу
            allReleases = unique.filter { ($0.name ?? "").contains("Xcode") }
            releases = Array(allReleases.prefix(pageSize))
            
        } catch {
            errorText = error.localizedDescription
            allReleases = []
            releases = []
        }
    }
    
    func loadMoreIfNeeded(currentItem item: XcodeReleaseModel?) {
        guard hasMorePages else { return }
        guard let item else { return }
        // When the last visible item appears, append next page
        if item.id == releases.last?.id {
            appendNextPage()
            print("Loading more...")
        }
    }
    
    private func appendNextPage() {
        guard !isLoadingMore else { return }
        guard hasMorePages else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }
        
        let start = releases.count
        let end = min(start + pageSize, allReleases.count)
        releases.append(contentsOf: allReleases[start..<end])
    }
}

