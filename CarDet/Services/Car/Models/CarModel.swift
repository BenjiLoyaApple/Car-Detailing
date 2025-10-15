//
//  CarModel.swift
//  CarDet
//
//  Created by BenjiLoya on 15.10.2025.
//

import Foundation

// MARK: - Body type
enum BodyType: String, Codable, CaseIterable {
    case sedan = "Седан"
    case hatchback = "Хэтчбек"
    case suv = "Внедорожник / SUV"
    case coupe = "Купе"
    case convertible = "Кабриолет"
    case pickup = "Пикап"
    case minivan = "Минивэн"
    case wagon = "Универсал"
    case other = "Другое"
}

// MARK: - Car Model (CloudKit: recordType "Car", reference to User)
struct CarModel: Identifiable, Codable, Hashable {
    let id: String
    let userId: String
    let brand: String
    let model: String
    let year: Int
    let bodyType: BodyType
    let color: String?
    let licensePlate: String?
    let mileage: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case brand
        case model
        case year
        case bodyType
        case color
        case licensePlate
        case mileage
    }
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        brand: String,
        model: String,
        year: Int,
        bodyType: BodyType,
        color: String? = nil,
        licensePlate: String? = nil,
        mileage: Int? = nil
    ) {
        self.id = id
        self.userId = userId
        self.brand = brand
        self.model = model
        self.year = year
        self.bodyType = bodyType
        self.color = color
        self.licensePlate = licensePlate
        self.mileage = mileage
    }
}

extension CarModel {
    static var mock: Self { mocks[0] }
    
    private static let user1 = "user_01"
    private static let user2 = "user_02"
    private static let user3 = "user_03"
    
    private static let carBMW     = "car_bmw_x5"
    private static let carToyota  = "car_toyota_camry"
    private static let carAudi    = "car_audi_a6"
    private static let carMerc    = "car_mercedes_gls450"
    private static let carFord    = "car_ford_ranger"
    
    static var mocks: [Self] {
        [
            CarModel(
                id: carBMW,
                userId: user1,
                brand: "BMW",
                model: "X5",
                year: 2021,
                bodyType: .suv,
                color: "Черный",
                licensePlate: "A123BC77",
                mileage: 35000
            ),
            CarModel(
                id: carToyota,
                userId: user1,
                brand: "Toyota",
                model: "Camry",
                year: 2018,
                bodyType: .sedan,
                color: "Белый",
                licensePlate: "D555EE77",
                mileage: 82000
            ),
            CarModel(
                id: carAudi,
                userId: user2,
                brand: "Audi",
                model: "A6",
                year: 2020,
                bodyType: .sedan,
                color: "Серый",
                licensePlate: "E777TT99",
                mileage: 27000
            ),
            CarModel(
                id: carMerc,
                userId: user3,
                brand: "Mercedes-Benz",
                model: "GLS 450",
                year: 2022,
                bodyType: .suv,
                color: "Синий металлик",
                licensePlate: "M123MM77",
                mileage: 12000
            ),
            CarModel(
                id: carFord,
                userId: user3,
                brand: "Ford",
                model: "Ranger",
                year: 2019,
                bodyType: .pickup,
                color: "Оранжевый",
                licensePlate: "F999FF77",
                mileage: 56000
            )
        ]
    }
    
    static func orders(for carId: String) -> [OrderModel] {
        OrderModel.mocks.filter { $0.carId == carId }
    }
}
