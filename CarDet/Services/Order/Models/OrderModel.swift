//
//  CarOrder.swift
//  CarDet
//
//  Created by BenjiLoya on 14.10.2025.
//

import Foundation

// MARK: - Order Status
enum OrderStatus: String, Codable, CaseIterable {
    case scheduled = "Запланирован"
    case inProgress = "В процессе"
    case completed = "Завершён"
    case canceled = "Отменён"
    
    // Вспомогательный порядок для сортировки по статусу (если понадобится)
    var sortOrder: Int {
        switch self {
        case .scheduled: return 0
        case .inProgress: return 1
        case .completed: return 2
        case .canceled: return 3
        }
    }
}

// MARK: - Service Type (identifier)
// Идентификатор услуги. Метаданные (базовая цена/описание) берём из каталога DetailingServiceInfo.
enum DetailingService: String, Codable, CaseIterable, Hashable {
    case exteriorWash = "Внешняя мойка"
    case interiorCleaning = "Химчистка салона"
    case polishing = "Полировка кузова"
    case waxing = "Нанесение воска"
    case ceramicCoating = "Керамическое покрытие"
    case engineCleaning = "Очистка двигателя"
    case headlightRestoration = "Полировка фар"
    case odorRemoval = "Удаление запахов"
    case deepDetailing = "Глубокий детейлинг"
    case other = "Другое"
    
    // Удобные геттеры метаданных (для моков/дефолтов).
    // В заказе эти значения можно переопределить (см. OrderItem.unitPrice, customDescription).
    var info: DetailingServiceInfo {
        DetailingServiceInfo.defaultCatalog[self] ?? .init(
            service: self,
            basePrice: 0,
            shortDescription: rawValue
        )
    }
    
    // Базовая цена по каталогу (можно переопределить в OrderItem.unitPrice).
    var basePrice: Double { info.basePrice }
    
    // Короткое описание по каталогу (можно переопределить в OrderItem.customDescription).
    var shortDescription: String? { info.shortDescription }
}

// MARK: - Service metadata model
// Каталог дефолтных метаданных услуг. Источник правды для "базовых" значений.
// В заказе значения фиксируются и при необходимости переопределяются (см. OrderItem).
struct DetailingServiceInfo: Codable, Equatable, Hashable {
    let service: DetailingService
    let basePrice: Double
    let shortDescription: String?   // можно переопределить описание (OrderItem.customDescription)
    
    enum CodingKeys: String, CodingKey {
        case service
        case basePrice
        case shortDescription
    }
    
    // Каталог мок-метаданных (в проде будет в БД/CloudKit)
    static let defaultCatalog: [DetailingService: DetailingServiceInfo] = [
        .exteriorWash: .init(
            service: .exteriorWash,
            basePrice: 60,
            shortDescription: "Бережная мойка кузова с сушкой"
        ),
        .interiorCleaning: .init(
            service: .interiorCleaning,
            basePrice: 80,
            shortDescription: "Химчистка сидений и ковров, пылесос, пластик"
        ),
        .polishing: .init(
            service: .polishing,
            basePrice: 150,
            shortDescription: "Полировка кузова с восстановлением блеска"
        ),
        .waxing: .init(
            service: .waxing,
            basePrice: 60,
            shortDescription: "Нанесение защитного воска"
        ),
        .ceramicCoating: .init(
            service: .ceramicCoating,
            basePrice: 250,
            shortDescription: "Керамическое покрытие кузова"
        ),
        .engineCleaning: .init(
            service: .engineCleaning,
            basePrice: 90,
            shortDescription: "Деликатная очистка подкапотного пространства"
        ),
        .headlightRestoration: .init(
            service: .headlightRestoration,
            basePrice: 70,
            shortDescription: "Полировка и восстановление прозрачности фар"
        ),
        .odorRemoval: .init(
            service: .odorRemoval,
            basePrice: 75,
            shortDescription: "Удаление запахов с обработкой салона"
        ),
        .deepDetailing: .init(
            service: .deepDetailing,
            basePrice: 220,
            shortDescription: "Комплексный глубокий детейлинг"
        ),
        .other: .init(
            service: .other,
            basePrice: 0,
            shortDescription: "Другая услуга по согласованию"
        ),
    ]
}

// MARK: - Order Model (CloudKit: recordType "Order", references to User & Car)
// Храним итоговую сумму totalPrice как источник правды (для истории/бухгалтерии).
// При необходимости можно сверять с computedTotalPrice.
struct OrderModel: Identifiable, Codable, Hashable {
    let id: String
    let userId: String
    let carId: String
    let date: Date
    let items: [OrderItem]      // позиции заказа с ценой/описанием на момент заказа
    let totalPrice: Double      // итоговая сумма (зафиксирована)
    let notes: String?          // можно переопределить/добавить комментарий к заказу
    let status: OrderStatus
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case carId
        case date
        case items
        case totalPrice
        case notes
        case status
    }
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        carId: String,
        date: Date = Date(),
        items: [OrderItem],
        totalPrice: Double? = nil,   // если не передали, посчитаем из items
        notes: String? = nil,        // можно переопределить комментарий
        status: OrderStatus = .scheduled
    ) {
        self.id = id
        self.userId = userId
        self.carId = carId
        self.date = date
        self.items = items
        let computed = items.reduce(0) { $0 + $1.lineTotal }
        self.totalPrice = totalPrice ?? computed
        self.notes = notes
        self.status = status
    }
    
    var computedTotalPrice: Double {
        items.reduce(0) { $0 + $1.lineTotal }
    }
    var itemCount: Int { items.count }
    var hasNotes: Bool { !(notes ?? "").isEmpty }
    var formattedTotalPrice: String {
        PriceFormatter.shared.string(from: totalPrice)
    }
}

// MARK: - Local price formatter (currency-agnostic)
// На проде можно заменить на локаль/валюту из настроек пользователя.
private final class PriceFormatter {
    static let shared = PriceFormatter()
    private let formatter: NumberFormatter
    
    private init() {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = Locale.current
        formatter = f
    }
    
    func string(from value: Double) -> String {
        formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }
}

// MARK: - Order Item (позиция заказа)
// Позиция фиксирует цену/описание на момент заказа.
// unitPrice можно переопределить относительно каталога (скидка/акция).
// customDescription можно переопределить относительно каталога (уточнение для клиента/мастера).
struct OrderItem: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let service: DetailingService
    let unitPrice: Double              // можно переопределить цену (по умолчанию из каталога)
    let customDescription: String?     // можно переопределить описание (по умолчанию из каталога)
    
    enum CodingKeys: String, CodingKey {
        case id
        case service
        case unitPrice
        case customDescription
    }
    
    init(
        id: String = UUID().uuidString,
        service: DetailingService,
        unitPrice: Double? = nil,          // можно переопределить цену
        customDescription: String? = nil   // можно переопределить описание
    ) {
        self.id = id
        self.service = service
        self.unitPrice = unitPrice ?? service.basePrice
        self.customDescription = customDescription
    }
    
    var lineTotal: Double { unitPrice }
    var displayDescription: String {
        customDescription ?? service.shortDescription ?? service.rawValue
    }
    var isCustomPriced: Bool {
        unitPrice != service.basePrice
    }
    var formattedUnitPrice: String {
        PriceFormatter.shared.string(from: unitPrice)
    }
}

extension OrderModel {
    static var mock: Self { mocks[0] }
    
    // Моки заказов с позициями (items). totalPrice совпадает с суммой позиций.
    static var mocks: [Self] {
        [
            OrderModel(
                userId: "user_01",
                carId: "car_bmw_x5",
                items: [
                    OrderItem(service: .exteriorWash),
                    OrderItem(service: .waxing)
                ],
                notes: "Использовать премиум-воск",
                status: .completed
            ),
            OrderModel(
                userId: "user_01",
                carId: "car_toyota_camry",
                items: [
                    OrderItem(service: .interiorCleaning),
                    OrderItem(service: .odorRemoval, customDescription: "Салон: особое внимание к багажнику")
                ],
                notes: nil,
                status: .scheduled
            ),
            OrderModel(
                userId: "user_02",
                carId: "car_audi_a6",
                items: [
                    OrderItem(service: .deepDetailing),
                    OrderItem(service: .engineCleaning),
                    // Переопределим цену керамики под акцию
                    OrderItem(service: .ceramicCoating, unitPrice: 230)
                ],
                notes: "Full-пакет, скидка на керамику",
                status: .inProgress
            ),
            OrderModel(
                userId: "user_03",
                carId: "car_mercedes_gls450",
                items: [
                    OrderItem(service: .exteriorWash),
                    OrderItem(service: .ceramicCoating, customDescription: "Керамика 1 слой (кузов)")
                ],
                notes: nil,
                status: .scheduled
            ),
            OrderModel(
                userId: "user_03",
                carId: "car_ford_ranger",
                items: [
                    OrderItem(service: .polishing),
                    OrderItem(service: .waxing)
                ],
                notes: nil,
                status: .completed
            )
        ]
    }
    
    static func orders(forUser userId: String) -> [OrderModel] {
        mocks.filter { $0.userId == userId }
    }
    
    static func orders(forCar carId: String) -> [OrderModel] {
        mocks.filter { $0.carId == carId }
    }
}
