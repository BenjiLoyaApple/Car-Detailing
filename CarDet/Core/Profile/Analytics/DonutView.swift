//
//  DonutView.swift
//  CarDet
//
//  Created by BenjiLoya on 27.08.2025.
//

import SwiftUI
import Charts

// Визуализация распределения заказов по статусам в виде "пончика"
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
            .accessibilityLabel(item.status.rawValue)
            .accessibilityValue("\(item.count)")
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
                        // число — плавная цифровая анимация
                        Text("\(centerValue)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 1.0), value: centerValue)

                        // подпись — простой fade при смене статуса
                        ZStack {
                            Text(centerStatus.rawValue)
                                .font(.system(size: 12, weight: .light))
                                .foregroundStyle(.secondary)
                                .id(centerStatus)
                                .transition(.opacity)
                        }
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .animation(.easeInOut(duration: 0.3), value: centerStatus)
                    }
                    .position(x: f.midX, y: f.midY)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Selected status")
                    .accessibilityValue("\(centerStatus.rawValue): \(centerValue)")
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

// Колонка с разбивкой по статусам
struct StatusBreakdownColumn: View {
    let counts: [StatusCount]
    private var order: [OrderStatus] { counts.filter { $0.count > 0 }.map(\.status) }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(order, id: \.self) { status in
                HStack(spacing: 6) {
                    Text("\(status.rawValue):")
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(.secondary)
                    Text("\(value(for: status))")
                        .font(.system(size: 14, weight: .semibold))
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Breakdown by status")
    }

    private func value(for status: OrderStatus) -> Int {
        counts.first(where: { $0.status == status })?.count ?? 0
    }
}

// Виджет месячной аналитики: пончик + выбор месяца + разбивка
struct MonthlyAnalyticsView: View {
    /// Показывать плейсхолдер (бывший skeleton).
    var isLoading: Bool = false

    /// DI: функция, считающая метрики для выбранного месяца.
    typealias CountsComputer = (Date) -> [StatusCount]
    let computeCounts: CountsComputer

    @State private var month: Date = Date()

    /// Нормализуем дату к началу месяца
    private func monthStart(_ date: Date) -> Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: date)
        return cal.date(from: comps) ?? date
    }

    private var data: [StatusCount] { computeCounts(monthStart(month)) }

    var body: some View {
        Card {
            CardHeader(icon: "chart.pie.fill", title: "Monthly activity")

            if isLoading {
                ActivitySummaryPlaceholder()
                    .padding(.top)
            } else {
                HStack(alignment: .top, spacing: 30) {
                    MonthlyStatusDonutChart(data: data)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        MonthPicker(
                            month: $month,
                            minMonth: nil,
                            maxMonth: Date()
                        )
                        
                        StatusBreakdownColumn(counts: data)
                    }
                }
                .padding(.top, 10)
            }
        }
        .skeleton(isRedacted: isLoading)
        .allowsHitTesting(!isLoading)
    }

    //MARK: - Placeholder
    @ViewBuilder
    private func ActivitySummaryPlaceholder() -> some View {
        let donutSize: CGFloat = 160

        HStack(alignment: .top, spacing: 40) {
            VStack(alignment: .leading, spacing: 30) {
                Circle()
                    .stroke(Color.primary.opacity(0.08), lineWidth: 20)
                    .frame(width: donutSize, height: donutSize)
                    .overlay {
                        VStack(spacing: 6) {
                            placeholderBar(width: 32, height: 32, alpha: 0.15)
                            placeholderBar(width: 56, height: 14, alpha: 0.1, corner: 6)
                        }
                    }
                
                VStack(spacing: 10) {
                    ForEach(0..<2, id: \.self) { _ in
                        HStack(spacing: 14) {
                            ForEach(0..<2, id: \.self) { _ in
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(Color.primary.opacity(0.10))
                                        .frame(width: 8, height: 8)
                                    placeholderBar(width: 55, height: 8, alpha: 0.10)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.leading, 10)
            
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 16)
                    .frame(height: 30)
                    .foregroundStyle(.gray.opacity(0.2))
                    .padding(.bottom, 10)

                placeholderMetricRow(labelWidth: 52, valueWidth: 22)
                placeholderMetricRow(labelWidth: 70, valueWidth: 22)
                placeholderMetricRow(labelWidth: 46, valueWidth: 11)
                placeholderMetricRow(labelWidth: 64, valueWidth: 22)
            }
            
        }
        .padding(.top, 10)
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


// MARK: - Preview
#Preview("Summary – Donut") {
    VStack(spacing: 50) {
        // Плейсхолдер
        MonthlyAnalyticsView(isLoading: true) { _ in [] }

        // Игрушечные метрики (зависят от месяца) на OrderStatus
        MonthlyAnalyticsView(isLoading: false) { month in
            let m = Calendar.current.component(.month, from: month)
            return OrderStatus.allCases.enumerated().map { idx, st in
                StatusCount(status: st, count: (idx * 2 + m) % 7)
            }
        }
    }
    .padding()
    .background(Color.themeBG)
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
