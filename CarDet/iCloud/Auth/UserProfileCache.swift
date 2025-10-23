//
//  UserProfileCache.swift
//  TaskManager
//
//  Created by Benji Loya on 21.05.2025.
//

/*
import SwiftUI
import Foundation
import CloudKit
import Combine

final class UserProfileCache: ObservableObject {
    static let shared = UserProfileCache()
    
    @Published private(set) var profiles: [String: UserModel] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}

    func loadProfile(for userID: String) {
        guard profiles[userID] == nil else { return }

        let recordID = CKRecord.ID(recordName: userID)
        
        CloudKitUtility
            .fetchRecord(by: recordID, recordType: "UserProfile", database: .private)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("❌ Ошибка загрузки профиля: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] (profile: UserModel?) in
                guard let profile = profile else { return }
                DispatchQueue.main.async {
                    self?.profiles[userID] = profile
                }
            })
            .store(in: &cancellables)
    }

    func profile(for userID: String) -> UserModel? {
        return profiles[userID]
    }
    
    func insertMockProfile(_ profile: UserModel) {
           profiles[profile.record.recordID.recordName] = profile
       }
}



import Foundation
import Combine
import CloudKit
import SwiftUI

final class UserSession: ObservableObject {
    
    static let shared = UserSession()
    
    @Published var currentProfile: UserModel?

    @AppStorage("userProfileRecordID") private var savedRecordName: String?

    private var cancellables = Set<AnyCancellable>()

    private init() {}

    func loadProfileIfNeeded() {
        guard currentProfile == nil else { return }

        if let recordName = savedRecordName {
            let recordID = CKRecord.ID(recordName: recordName)
            CloudKitUtility
                .fetchRecord(by: recordID, recordType: "UserProfile", database: .private)
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("⚠️ Не удалось загрузить профиль по сохранённому recordID: \(error.localizedDescription)")
                        self.loadWithPredicateFallback()
                    }
                }, receiveValue: { [weak self] (profile: UserModel?) in
                    if let profile = profile {
                        DispatchQueue.main.async {
                            self?.currentProfile = profile
                            print("✅ Профиль загружен по savedRecordID: \(profile.fullName)")
                        }
                    } else {
                        self?.loadWithPredicateFallback()
                    }
                })
                .store(in: &cancellables)
        } else {
            loadWithPredicateFallback()
        }
    }

    private func loadWithPredicateFallback() {
        CloudKitUtility
            .fetch(predicate: NSPredicate(value: true), recordType: "UserProfile", database: .private)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("❌ Failed to load current profile: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] (profiles: [UserModel]) in
                if let profile = profiles.first {
                    DispatchQueue.main.async {
                        self?.currentProfile = profile
                        self?.savedRecordName = profile.record.recordID.recordName
                        print("✅ Профиль загружен (по предикату) и сохранён")
                    }
                } else {
                    print("⚠️ Профиль не найден")
                }
            })
            .store(in: &cancellables)
    }

    /// Принудительно перезагружает профиль
    func reloadProfile() {
        currentProfile = nil
        loadProfileIfNeeded()
    }

    /// Очищает текущую сессию и savedRecordID
    func clearSession() {
        print("🧹 Очистка сессии пользователя")
        currentProfile = nil
        savedRecordName = nil
    }

    /// Combine Publisher для подписки на изменения текущего профиля
    var profilePublisher: AnyPublisher<UserModel?, Never> {
        $currentProfile.eraseToAnyPublisher()
    }
    
    func deleteProfile(completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let profile = currentProfile else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Профиль не найден"])))
            return
        }

        CloudKitUtility
            .delete(item: profile, database: .private)
            .sink(receiveCompletion: { result in
                if case let .failure(error) = result {
                    completion(.failure(error))
                }
            }, receiveValue: { success in
                if success {
                    self.clearSession()
                    completion(.success(true))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Удаление не удалось"])))
                }
            })
            .store(in: &cancellables)
    }
}


extension UserSession {
    func ensureProfileLoaded(completion: @escaping () -> Void) {
        if currentProfile != nil {
            completion()
        } else {
            profilePublisher
                .filter { $0 != nil }
                .first()
                .sink { _ in
                    completion()
                }
                .store(in: &cancellables)
        }
    }
}

*/
