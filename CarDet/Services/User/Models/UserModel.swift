//
//  UserModel.swift
//  AIChatCourse
//
//  Created by Benji Loya on 10/9/24.
//

import Foundation
import SwiftUI

// MARK: - City (типобезопасный справочник городов)
enum City: String, Codable, CaseIterable, Identifiable {
    case ufa
    case yekaterinburg
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .ufa: "Уфа"
        case .yekaterinburg: "Екатеринбург"
        }
    }
}

// MARK: - User Model (CloudKit: recordType "User")
struct UserModel: Identifiable, Codable, Hashable {
    var id: String { userId }
    
    let userId: String
    let dateCreated: Date?
    let didCompleteOnboarding: Bool?
    let fullName: String
    let emailAddress: String
    let city: City
    let phoneNumber: String?
    let userImage: String?
    
    enum CodingKeys: String, CodingKey {
        case userId
        case dateCreated
        case didCompleteOnboarding
        case fullName
        case emailAddress
        case city
        case phoneNumber
        case userImage
    }
    
    init(
        userId: String,
        dateCreated: Date? = nil,
        didCompleteOnboarding: Bool? = nil,
        fullName: String,
        emailAddress: String,
        city: City,
        phoneNumber: String? = nil,
        userImage: String? = nil
    ) {
        self.userId = userId
        self.dateCreated = dateCreated
        self.didCompleteOnboarding = didCompleteOnboarding
        self.fullName = fullName
        self.emailAddress = emailAddress
        self.city = city
        self.phoneNumber = phoneNumber
        self.userImage = userImage
    }
}

// MARK: - MOCKS (flat) + helpers как "сервисы"
extension UserModel {
    static var mock: Self {
        mocks[1]
    }
    
    static var mocks: [Self] {
        let users = ["user_01", "user_02", "user_03"]
        return [
            UserModel(
                userId: users[0],
                dateCreated: Date(),
                didCompleteOnboarding: true,
                fullName: "Benji Loya",
                emailAddress: "benjiloya@example.com",
                city: .yekaterinburg,
                phoneNumber: "+971 50 123 4567",
                userImage: "https://picsum.photos/200/200"
            ),
            UserModel(
                userId: users[1],
                dateCreated: Date().addingTimeInterval(-86400 * 3),
                didCompleteOnboarding: true,
                fullName: "Emily Johnson",
                emailAddress: "emily.j@example.com",
                city: .yekaterinburg,
                phoneNumber: "+971 52 654 3210",
                userImage: "https://picsum.photos/200/210"
            ),
            UserModel(
                userId: users[2],
                dateCreated: Date().addingTimeInterval(-76400 * 7),
                didCompleteOnboarding: true,
                fullName: "Michael Brown",
                emailAddress: "michael.brown@example.com",
                city: .ufa,
                phoneNumber: "+971 55 876 5432",
                userImage: "https://picsum.photos/200/220"
            )
        ]
    }
    
    static func cars(for userId: String) -> [CarModel] {
        CarModel.mocks.filter { $0.userId == userId }
    }
    
    static func orders(for userId: String) -> [OrderModel] {
        OrderModel.mocks.filter { $0.userId == userId }
    }
}

// MARK: - UserModel updating helper
extension UserModel {
    /// Возвращает копию пользователя с обновлёнными полями.
    /// Неизменяемые/служебные: userId, dateCreated (их не трогаем).
    func updating(
        fullName: String? = nil,
        emailAddress: String? = nil,
        city: City? = nil,
        phoneNumber: String? = nil,
        userImage: String? = nil,
        didCompleteOnboarding: Bool? = nil
    ) -> UserModel {
        UserModel(
            userId: userId,
            dateCreated: dateCreated,
            didCompleteOnboarding: didCompleteOnboarding ?? self.didCompleteOnboarding,
            fullName: fullName ?? self.fullName,
            emailAddress: emailAddress ?? self.emailAddress,
            city: city ?? self.city,
            phoneNumber: phoneNumber ?? self.phoneNumber,
            userImage: userImage ?? self.userImage
        )
    }
}
