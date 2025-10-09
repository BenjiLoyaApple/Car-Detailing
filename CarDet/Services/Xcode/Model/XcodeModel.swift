//
//  XcodeModel.swift
//  XcodeReleases
//
//  Created by BenjiLoya on 25.09.2025.
//

import Foundation

// MARK: - Models
struct XcodeReleaseModel: Identifiable, Decodable {
    var id: String {
        if let sha = checksums?.sha1, !sha.isEmpty {
            return "sha1:\(sha.lowercased())"
        }
        let url     = links?.download?.url ?? "-"
        let build   = version?.build ?? "-"
        let number  = version?.number ?? "-"
        let nameKey = name ?? "-"
        let dateKey = date.map { "\($0.year)-\($0.month)-\($0.day)" } ?? "nodate"
        let archKey = (links?.download?.architectures ?? []).sorted().joined(separator: ",")

        return "key:\(url)|\(build)|\(number)|\(nameKey)|\(dateKey)|\(archKey)"
    }

    let name: String?
    let version: Version?
    let date: SimpleDate?
    let links: Links?
    let requires: String?
    let sdks: SDKs?
    let checksums: Checksums?

    var displayVersion: String {
        let v = version?.number ?? "—"
        if let build = version?.build { return "Xcode \(v) (\(build))" }
        return "Xcode \(v)"
    }
    var displayDate: Date? {
        guard let date else { return nil }
        var comps = DateComponents()
        comps.year = date.year
        comps.month = date.month
        comps.day = date.day
        return Calendar.current.date(from: comps)
    }
    var downloadURL: URL? { URL(string: links?.download?.url ?? "") }
    var architectures: [String] { links?.download?.architectures ?? [] }

    struct Version: Decodable {
        let build: String?
        let number: String?
    }
    struct SimpleDate: Decodable {
        let day: Int
        let month: Int
        let year: Int
    }
    struct Links: Decodable {
        let download: Download?
        let notes: NoteLink?
        struct Download: Decodable {
            let architectures: [String]?
            let url: String
        }
        struct NoteLink: Decodable { let url: String? }
    }
    struct SDKs: Decodable {
        let iOS: [SDKItem]?
        let macOS: [SDKItem]?
        let tvOS: [SDKItem]?
        let watchOS: [SDKItem]?
        let visionOS: [SDKItem]?
        struct SDKItem: Decodable {
            let build: String?
            let number: String?
        }
    }
    struct Checksums: Decodable { let sha1: String? }
}
