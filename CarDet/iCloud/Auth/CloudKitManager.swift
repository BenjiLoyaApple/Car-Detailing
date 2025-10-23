//
//  CloudKitManager.swift
//  iCloudDemo
//
//  Created by Benji Loya on 05.05.2025.
//

/*
import Foundation
import Combine
import CloudKit

class CloudKitManager: ObservableObject {
    @Published var isReady: Bool = false
    @Published var userName: String = ""
    @Published var isSignedIn: Bool = false
    @Published var hasPermission: Bool = false
    @Published var error: String = ""
    @Published var shouldPromptCreateProfile: Bool = false
    @Published var didCreateUserProfile: Bool = false
    @Published var userProfile: UserModel? = nil
    private var cancellables = Set<AnyCancellable>()

    init(shouldInitialize: Bool = true) {
        if shouldInitialize {
            initializeSession()
        }
    }

    func initializeSession() {
        CloudKitUtility.getiCloudStatus()
            .eraseToAnyPublisher()
            .flatMap { isSignedIn -> AnyPublisher<Bool, Error> in
                DispatchQueue.main.async {
                    self.isSignedIn = isSignedIn
                }
                return CloudKitUtility.requestApplicationPermission().eraseToAnyPublisher()
            }
            .flatMap { permissionGranted -> AnyPublisher<String, Error> in
                DispatchQueue.main.async {
                    self.hasPermission = permissionGranted
                }
                return CloudKitUtility.discoverUserIdentity().eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let err) = completion {
                    self.error = err.localizedDescription
                }
            } receiveValue: { name in
                self.userName = name
                self.loadUserProfile()
            }
            .store(in: &cancellables)
    }

    func requestPermissionManually() {
        CloudKitUtility.requestApplicationPermission()
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { [weak self] granted in
                self?.hasPermission = granted
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Унифицированный метод загрузки профиля
     func loadUserProfile() {
         CloudKitUtility.userProfileRecordID { recordID in
             guard let recordID = recordID else {
                 DispatchQueue.main.async {
                     self.error = "Не удалось получить userRecordID"
                     self.shouldPromptCreateProfile = true
                     self.isReady = true
                 }
                 return
             }

             CloudKitUtility.fetchRecord(
                 by: recordID,
                 recordType: "UserProfile",
                 database: .private
             )
             .receive(on: DispatchQueue.main)
             .sink(receiveCompletion: { completion in
                 switch completion {
                 case .finished: break
                 case .failure(let error):
                     if let ckError = error as? CKError, ckError.code == .unknownItem {
                         print("[CloudKit] 🟡 Профиль не найден – нужно создать")
                         self.userProfile = nil
                         self.shouldPromptCreateProfile = true
                     } else {
                         self.error = error.localizedDescription
                         self.shouldPromptCreateProfile = true
                     }
                     self.isReady = true
                 }
             }, receiveValue: { profile in
                 self.userProfile = profile
                 self.shouldPromptCreateProfile = (profile == nil)
                 self.isReady = true
                 print("[CloudKitManager] ✅ Профиль найден: \(profile?.fullName ?? "nil")")
                 
                 UserSession.shared.currentProfile = profile
             })
             .store(in: &self.cancellables)
         }
     }
}
*/
