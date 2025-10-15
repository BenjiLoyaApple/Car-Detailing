//
//  Analytics.swift
//  CarDet
//
//  Created by BenjiLoya on 15.08.2025.
//

import Foundation
import Combine

// ================================================================
// MARK: - Adapters (композиционный слой фичи/экрана)
// Подключай это расширение там, где реально используешь OrderModel.
// Ядро не зависит от конкретной реализации.
// ================================================================

// Делает вашу доменную модель совместимой с ядром аналитики заказов
extension OrderModel: OrderLike {
    var orderDate: Date { date }
    var ownerID: String { userId }
    var orderStatus: OrderStatus { status }
}

/// Протокол для развязки аналитики от конкретной модели заказов.
protocol OrderLike {
    var orderDate: Date { get }        // одна дата заказа
    var orderStatus: OrderStatus { get }
    var ownerID: String { get }        // владелец заказа (пользователь)
}

// ================================================================
// MARK: - Analytics Core (чистое ядро, без знаний о OrderModel)
// ================================================================

/// Кол-во заказов по статусу.
struct StatusCount: Identifiable, Equatable {
    let status: OrderStatus
    let count: Int
    var id: String { status.rawValue }
}

/// Семантический сахар для частых фильтров.
/// Можно не использовать — см. главный API с `filter:`.
enum OrderScope {
    case all
    case ownerOnly(String)         // заказы конкретного пользователя
    // При необходимости можно добавить:
    // case carOnly(String)
    // case ownerAndCar(userId: String, carId: String)

    /// Преобразуем scope в предикат.
    func toPredicate<T: OrderLike>() -> (T) -> Bool {
        switch self {
        case .all:
            return { _ in true }
        case .ownerOnly(let uid):
            return { $0.ownerID == uid }
        }
    }
}

/// Чистая бизнес-логика (generic для любых типов, совместимых с OrderLike).
enum OrderAnalytics {
    /// Главный API: передай произвольный предикат-фильтр.
    /// - Parameters:
    ///   - orders: массив сущностей (например, [OrderModel])
    ///   - monthOf: любая дата внутри интересующего месяца
    ///   - calendar: календарь (по умолчанию текущий)
    ///   - filter: предикат для дополнительной фильтрации (владелец, машина и т.д.)
    static func countsByStatus<T: OrderLike>(
        orders: [T],
        in monthOf: Date,
        calendar: Calendar = .current,
        filter: (T) -> Bool = { _ in true }
    ) -> [StatusCount] {

        guard let monthInterval = calendar.dateInterval(of: .month, for: monthOf) else { return [] }

        // 1) попадает ли заказ в месяц (по дате заказа)
        @inline(__always)
        func isInMonth(_ o: T) -> Bool {
            monthInterval.contains(o.orderDate)
        }

        // 2) применяем фильтры и считаем
        var counts: [OrderStatus: Int] = [:]
        counts.reserveCapacity(OrderStatus.allCases.count)

        for o in orders where isInMonth(o) && filter(o) {
            counts[o.orderStatus, default: 0] += 1
        }

        // 3) возвращаем полный набор статусов (включая нули)
        return OrderStatus.allCases.map { StatusCount(status: $0, count: counts[$0] ?? 0) }
    }

    /// Сахар: тот же подсчёт, но через `OrderScope`.
    static func countsByStatus<T: OrderLike>(
        orders: [T],
        in monthOf: Date,
        scope: OrderScope,
        calendar: Calendar = .current
    ) -> [StatusCount] {
        countsByStatus(
            orders: orders,
            in: monthOf,
            calendar: calendar,
            filter: scope.toPredicate()
        )
    }
}

// ================================================================
// MARK: - OrderStore (универсальный источник, generic)
// ================================================================
/// Универсальный стор заказов.
/// - Потокобезопасен: `@MainActor` гарантирует, что Published-свойства меняются на главном потоке.
/// - `loader` инжектируется, можно подменять в тестах/превью.
@MainActor
final class OrderStore<T: OrderLike>: ObservableObject {
    @Published var orders: [T] = []
    @Published var isLoading = true
    @Published var error: Error?

    private let loader: () async throws -> [T]
    private var loadTask: Task<Void, Never>? // для отмены при повторной загрузке/деинициализации

    init(loader: @escaping () async throws -> [T]) {
        self.loader = loader
        self.loadTask = Task { await reload() }
    }

    deinit { loadTask?.cancel() }

    func reload() async {
        loadTask?.cancel()
        isLoading = true
        error = nil

        loadTask = Task { [loader] in
            do {
                let result = try await loader()
                if Task.isCancelled { return }
                self.orders = result
            } catch {
                if Task.isCancelled { return }
                self.error = error
            }
            self.isLoading = false
        }
        await loadTask?.value
    }
}
