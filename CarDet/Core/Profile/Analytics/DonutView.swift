//
//  DonutView.swift
//  CarDet
//
//  Created by BenjiLoya on 27.08.2025.
//

import SwiftUI
import Charts

// ================================================================
// MARK: - Donut Chart (Orders by Status)
// ================================================================

struct MonthlyStatusDonutChart: View {
    let data: [StatusCount]
    var animateOnAppear: Bool = true

    @State private var progress: Double = 0
    @State private var selectedAngle: Double? = nil

    private var chartData: [StatusCount] { data.filter { $0.count > 0 } }
    private var countsByStatus: [OrderStatus: Int] {
        Dictionary(uniqueKeysWithValues: data.map { ($0.status, $0.count) })
    }
    private var defaultCenterStatus: OrderStatus {
        chartData.first(where: { $0.status == .inProgress })?.status
        ?? chartData.first?.status
        ?? .inProgress
    }

    private func status(at angle: Double) -> OrderStatus? {
        guard progress > 0 else { return nil }
        let a = angle / progress
        var acc = 0.0
        for sc in chartData {
            let next = acc + Double(sc.count)
            if a >= acc && a < next { return sc.status }
            acc = next
        }
        return nil
    }

    private var selectedStatus: OrderStatus? {
        guard let a = selectedAngle else { return nil }
        return status(at: a)
    }
    
    private var centerStatus: OrderStatus { selectedStatus ?? defaultCenterStatus }
    private var centerValue: Int { countsByStatus[centerStatus] ?? 0 }

    var body: some View {
        let donutSize: CGFloat = 170

        Chart(chartData, id: \.id) { item in
            SectorMark(
                angle: .value("Count", Double(item.count) * progress),
                innerRadius: .ratio(0.7),
                outerRadius: .ratio(1.0),
                angularInset: 1.0
            )
            .foregroundStyle(by: .value("Status", item.status.rawValue))
            .opacity(selectedStatus == nil || selectedStatus == item.status ? 1.0 : 0.3)
            .cornerRadius(2)
        }
        .chartLegend(position: .bottom, alignment: .center, spacing: 15)
        .chartPlotStyle { plot in
            plot.frame(width: donutSize, height: donutSize)
        }
        .frame(width: donutSize)
        .chartBackground { chartProxy in
            GeometryReader { geo in
                if let anchor = chartProxy.plotFrame {
                    let f = geo[anchor]
                    VStack(spacing: 2) {
                        Text("\(centerValue)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 1.0), value: centerValue)
                        
//                        Text(centerStatus.rawValue)
//                            .font(.system(size: 12, weight: .light))
//                            .foregroundStyle(.secondary)
//                            .id(centerStatus)
//                            .transition(.opacity)
                        ZStack {
                            Text(centerStatus.rawValue)
                                .font(.system(size: 12, weight: .light))
                                .foregroundStyle(.secondary)
                                .id(centerStatus)
                                .transition(Twirl())
                        }
                        .animation(.bouncy(duration: 0.5), value: centerStatus)
                    }
                    .position(x: f.midX, y: f.midY)
                }
            }
        }
        .chartAngleSelection(value: $selectedAngle)
        .onAppear {
            if animateOnAppear {
                progress = 0
                withAnimation(.easeInOut(duration: 1.2)) {
                    progress = 1
                }
            } else {
                progress = 1
            }
        }
    }
}

// ================================================================
// MARK: - MonthlyAnalyticsView (Uses universal Analytics)
// ================================================================

struct MonthlyAnalyticsView: View {
    @State private var month: Date = Date()
    var scope: OrderScope = .all
    var isLoading: Bool = false

    // Универсальная аналитика через новое ядро
    private var counts: [StatusCount] {
        Analytics.countsByStatus(
            orders: OrderModel.mocks,
            in: month,
            scope: scope
        )
    }

    var body: some View {
        Card {
            CardHeader(icon: "chart.pie.fill", title: "Активность за месяц")

            if isLoading {
                ActivitySummaryPlaceholder()
                    .padding(.top)
            } else {
                HStack(alignment: .top, spacing: 30) {
                    MonthlyStatusDonutChart(data: counts)
                    VStack(alignment: .leading, spacing: 10) {
                        MonthPicker(month: $month)
                        StatusBreakdownColumn(counts: counts)
                    }
                }
                .padding(.top, 10)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isLoading)
    }

    // ============================================================
    // MARK: - Placeholder (Skeleton style)
    // ============================================================
    @ViewBuilder
    private func ActivitySummaryPlaceholder() -> some View {
        let donutSize: CGFloat = 160

        HStack(alignment: .top, spacing: 40) {
            VStack(spacing: 24) {
                Circle()
                    .stroke(Color.primary.opacity(0.08), lineWidth: 20)
                    .frame(width: donutSize, height: donutSize)
                    .overlay {
                        VStack(spacing: 8) {
                            placeholderBar(width: 32, height: 32, alpha: 0.15)
                            placeholderBar(width: 56, height: 14, alpha: 0.1, corner: 6)
                        }
                    }

                VStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { _ in
                        HStack(spacing: 8) {
                            Circle().fill(Color.primary.opacity(0.10))
                                .frame(width: 8, height: 8)
                            placeholderBar(width: 60, height: 8, alpha: 0.10)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                RoundedRectangle(cornerRadius: 16)
                    .frame(height: 30)
                    .foregroundStyle(.gray.opacity(0.2))
                    .padding(.bottom, 8)

                ForEach(0..<4, id: \.self) { _ in
                    placeholderMetricRow(labelWidth: .random(in: 50...70), valueWidth: .random(in: 20...35))
                }
            }
        }
        .padding(.top, 10)
        .redacted(reason: .placeholder)
    }

    private func placeholderMetricRow(labelWidth: CGFloat, valueWidth: CGFloat) -> some View {
        HStack(spacing: 8) {
            placeholderBar(width: labelWidth, height: 10, alpha: 0.10)
            placeholderBar(width: valueWidth, height: 14, alpha: 0.16)
        }
    }

    private func placeholderBar(width: CGFloat, height: CGFloat, alpha: CGFloat, corner: CGFloat = 3) -> some View {
        RoundedRectangle(cornerRadius: corner, style: .continuous)
            .fill(Color.primary.opacity(alpha))
            .frame(width: width, height: height)
    }
}

// ================================================================
// MARK: - Breakdown Column
// ================================================================

struct StatusBreakdownColumn: View {
    let counts: [StatusCount]
    private var ordered: [OrderStatus] { counts.filter { $0.count > 0 }.map(\.status) }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(ordered, id: \.self) { status in
                HStack(spacing: 6) {
                    Text("\(status.rawValue):")
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(.secondary)
                    Text("\(value(for: status))")
                        .font(.system(size: 14, weight: .semibold))
                }
            }
        }
    }

    private func value(for status: OrderStatus) -> Int {
        counts.first(where: { $0.status == status })?.count ?? 0
    }
}

// ================================================================
// MARK: - Preview
// ================================================================

#Preview("Monthly Analytics – With Placeholder") {
    VStack(spacing: 40) {
        MonthlyAnalyticsView(isLoading: true)
        MonthlyAnalyticsView(scope: .ownerOnly("user_01"))
    }
    .padding()
}







//MARK: - Month Drag Picker
import SwiftUI

struct MonthPicker: View {
    @Binding var month: Date
    var minMonth: Date? = nil
    var maxMonth: Date? = nil

    var body: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(Color.primary.opacity(0.06))
            .frame(height: 32)
            .overlay {
                ZStack {
                    Text(Self.titleFormatter.string(from: monthStart(month)))
                        .font(.system(size: 10, weight: .medium))
                        .lineLimit(1)
                        .id(monthStart(month))
                        .transition(.opacity)
                }
            }
            .gesture(dragGesture)
    }

    // MARK: - Gestures
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 10)
            .onEnded { v in
                let horizontal = abs(v.translation.width) > abs(v.translation.height)
                let distanceOK = abs(v.translation.width) > 24
                guard horizontal, distanceOK else { return }
                if v.translation.width < 0 { step(+1) } else { step(-1) }
            }
    }

    // MARK: - Logic
    private func canStep(_ delta: Int) -> Bool {
        guard let new = Calendar.current.date(byAdding: .month, value: delta, to: monthStart(month)) else { return false }
        let m = monthStart(new)
        if let min = minMonth.map(monthStart), m < min { return false }
        if let max = maxMonth.map(monthStart), m > max { return false }
        return true
    }

    private func step(_ delta: Int) {
        guard canStep(delta),
              let new = Calendar.current.date(byAdding: .month, value: delta, to: monthStart(month))
        else { return }
        withAnimation(.easeInOut(duration: 0.6)) {
            month = new
        }
    }

    private func monthStart(_ date: Date) -> Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: date)
        return cal.date(from: comps) ?? date
    }

    private static let titleFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "LLLL yyyy"
        return df
    }()
}
