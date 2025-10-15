//
//  Analytics.swift
//  CarDet
//
//  Created by BenjiLoya on 15.08.2025.
//

import Foundation
import Combine

// ================================================================
// MARK: - Protocols (универсальные контракты для аналитики)
// ================================================================

/// Базовый контракт для любой сущности, поддерживающей аналитику заказов.
protocol OrderLike {
    var orderDate: Date { get }        // дата заказа
    var orderStatus: OrderStatus { get } // статус
    var ownerID: String { get }        // владелец (userId)
}

/// Расширенный контракт для заказов, содержащих позиции.
protocol OrderWithItems: OrderLike {
    var items: [OrderItem] { get }     // массив услуг
}

// Адаптация существующей модели
extension OrderModel: OrderWithItems {
    var orderDate: Date { date }
    var orderStatus: OrderStatus { status }
    var ownerID: String { userId }
}

// ================================================================
// MARK: - Scopes / Filters
// ================================================================

/// Предопределённые фильтры (owner, car и т.д.)
enum OrderScope {
    case all
    case ownerOnly(String)
    case carOnly(String)
    case ownerAndCar(userId: String, carId: String)

    func toPredicate<T: OrderLike>() -> (T) -> Bool {
        switch self {
        case .all:
            return { _ in true }
        case .ownerOnly(let uid):
            return { $0.ownerID == uid }
        case .carOnly(let carId):
            if let t = T.self as? OrderModel.Type {
                return { ($0 as? OrderModel)?.carId == carId }
            }
            return { _ in false }
        case .ownerAndCar(let uid, let carId):
            if let t = T.self as? OrderModel.Type {
                return {
                    guard let o = $0 as? OrderModel else { return false }
                    return o.userId == uid && o.carId == carId
                }
            }
            return { _ in false }
        }
    }
}

// ================================================================
// MARK: - Aggregates / DTOs
// ================================================================

/// Кол-во заказов по статусу
struct StatusCount: Identifiable, Equatable {
    let status: OrderStatus
    let count: Int
    var id: String { status.rawValue }
}

/// Срез по услугам (кол-во и сумма)
struct ServiceRevenueSlice: Identifiable, Equatable {
    let service: DetailingService
    let count: Int
    let revenue: Double
    var id: DetailingService { service }
    var title: String { service.rawValue }
}

// ================================================================
// MARK: - Unified Analytics Core
// ================================================================

enum Analytics {

    // MARK: Orders by Status
    static func countsByStatus<T: OrderLike>(
        orders: [T],
        in monthOf: Date,
        scope: OrderScope = .all,
        calendar: Calendar = .current
    ) -> [StatusCount] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: monthOf) else { return [] }
        let predicate = scope.toPredicate() as (T) -> Bool
        var counts: [OrderStatus: Int] = [:]

        for o in orders where monthInterval.contains(o.orderDate) && predicate(o) {
            counts[o.orderStatus, default: 0] += 1
        }

        return OrderStatus.allCases.map {
            StatusCount(status: $0, count: counts[$0] ?? 0)
        }
    }

    // MARK: Revenue by Service
    static func revenueByService<T: OrderWithItems>(
        orders: [T],
        in monthOf: Date,
        scope: OrderScope = .all,
        calendar: Calendar = .current
    ) -> [ServiceRevenueSlice] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: monthOf) else { return [] }
        let predicate = scope.toPredicate() as (T) -> Bool

        var counts: [DetailingService: Int] = [:]
        var sums: [DetailingService: Double] = [:]

        for order in orders where monthInterval.contains(order.orderDate) && predicate(order) {
            for item in order.items {
                counts[item.service, default: 0] += 1
                sums[item.service, default: 0] += item.unitPrice
            }
        }

        return DetailingService.allCases.compactMap {
            guard let c = counts[$0], let s = sums[$0] else { return nil }
            return ServiceRevenueSlice(service: $0, count: c, revenue: s)
        }
        .sorted { $0.revenue > $1.revenue }
    }
}

// ================================================================
// MARK: - Async Store (Combine-friendly)
// ================================================================

@MainActor
final class OrderStore<T: OrderLike>: ObservableObject {
    @Published var orders: [T] = []
    @Published var isLoading = true
    @Published var error: Error?

    private let loader: () async throws -> [T]
    private var loadTask: Task<Void, Never>?

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

// ================================================================
// MARK: - Preview Helpers (Mocks)
// ================================================================

#if DEBUG
extension Analytics {
    static func demoStatusCounts() -> [StatusCount] {
        countsByStatus(orders: OrderModel.mocks, in: Date())
    }

    static func demoRevenueSlices() -> [ServiceRevenueSlice] {
        revenueByService(orders: OrderModel.mocks, in: Date())
    }
}
#endif
