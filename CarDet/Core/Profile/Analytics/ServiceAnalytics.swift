//
//  ServiceAnalytics.swift
//  CarDet
//
//  Created by Assistant on 15.10.2025.
//

import Foundation

// MARK: - Aggregates

struct ServiceRevenueSlice: Identifiable, Equatable {
    let service: DetailingService
    let count: Int
    let revenue: Double
    var id: DetailingService { service }
}

extension ServiceRevenueSlice {
    var title: String { service.rawValue }
}

// MARK: - Core

enum ServiceAnalytics {
    /// Агрегируем позиции заказа по услугам за месяц.
    /// - Parameters:
    ///   - orders: массив заказов
    ///   - monthOf: любая дата внутри интересующего месяца
    ///   - calendar: календарь
    ///   - filter: предикат по заказу (например, владелец/машина)
    /// - Returns: массив срезов по услугам (count и revenue)
    static func revenueByService(
        orders: [OrderModel],
        in monthOf: Date,
        calendar: Calendar = .current,
        filter: (OrderModel) -> Bool = { _ in true }
    ) -> [ServiceRevenueSlice] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: monthOf) else { return [] }

        // фильтруем заказы в месяце
        let filtered = orders.filter { monthInterval.contains($0.date) && filter($0) }

        // собираем все позиции
        var counts: [DetailingService: Int] = [:]
        var sums: [DetailingService: Double] = [:]
        counts.reserveCapacity(DetailingService.allCases.count)
        sums.reserveCapacity(DetailingService.allCases.count)

        for order in filtered {
            for item in order.items {
                counts[item.service, default: 0] += 1
                sums[item.service, default: 0] += item.unitPrice
            }
        }

        // возвращаем только услуги, которые встречались (без нулевых)
        return DetailingService.allCases
            .compactMap { svc -> ServiceRevenueSlice? in
                guard let c = counts[svc], let s = sums[svc] else { return nil }
                return ServiceRevenueSlice(service: svc, count: c, revenue: s)
            }
            .sorted { $0.revenue > $1.revenue }
    }

    /// Сахар: через OrderScope (как в OrderAnalytics)
    static func revenueByService(
        orders: [OrderModel],
        in monthOf: Date,
        scope: OrderScope,
        calendar: Calendar = .current
    ) -> [ServiceRevenueSlice] {
        revenueByService(
            orders: orders,
            in: monthOf,
            calendar: calendar,
            filter: scope.toPredicate()
        )
    }
}

