//
//  ProductionDataService.swift
//  XcodeReleases
//
//  Created by BenjiLoya on 25.09.2025.
//

import SwiftUI
import Observation

// MARK: - Data layer (async/await)
protocol DataServiceProtocol {
    func getData() async throws -> [XcodeReleaseModel]
}

final class ProductionDataService: DataServiceProtocol {
    let url: URL
    init(url: URL = URL(string: "https://xcodereleases.com/data.json")!) {
        self.url = url
    }
    func getData() async throws -> [XcodeReleaseModel] {
        let (data, response) = try await URLSession.shared.data(from: url)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode([XcodeReleaseModel].self, from: data)
    }
}

final class MockDataService: DataServiceProtocol {
    let testData: [XcodeReleaseModel]
    init(data: [XcodeReleaseModel]? = nil) {
        self.testData = data ?? [
            XcodeReleaseModel(
                name: "Xcode (Apple Silicon)",
                version: .init(build: "17A321", number: "26.0"),
                date: .init(day: 9, month: 9, year: 2025),
                links: .init(
                    download: .init(architectures: ["arm64"],
                                    url: "https://download.developer.apple.com/Developer_Tools/Xcode_26_Release_Candidate/Xcode_26_Release_Candidate_Apple_silicon.xip"),
                    notes: .init(url: "https://developer.apple.com/documentation/xcode-release-notes/xcode-26-release-notes")
                ),
                requires: "15.6",
                sdks: nil,
                checksums: .init(sha1: "a34d15dbce643221898b26673e6872b84cec9191")
            )
        ]
    }
    func getData() async throws -> [XcodeReleaseModel] {
        // имитируем асинхронность (современный API Duration)
        try? await Task.sleep(for: .seconds(2))
        return testData
    }
}
