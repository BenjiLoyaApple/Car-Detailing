//
//  ServiceDonutView.swift
//  CarDet
//
//  Created by Assistant on 15.10.2025.
//

import SwiftUI
import Charts

// MARK: - Donut Chart (Revenue by Services)
struct ServiceDonutChart: View {
    let data: [ServiceRevenueSlice]
    var animateOnAppear: Bool = true

    @State private var progress: Double = 0
    @State private var selectedAngle: Double? = nil

    private var totalRevenue: Double { data.reduce(0) { $0 + $1.revenue } }
    private var chartData: [ServiceRevenueSlice] { data.filter { $0.revenue > 0 } }

    private func slice(at angle: Double) -> ServiceRevenueSlice? {
        guard progress > 0 else { return nil }
        let total = chartData.reduce(0.0) { $0 + $1.revenue }
        guard total > 0 else { return nil }
        let scaled = angle / progress
        var acc = 0.0
        for s in chartData {
            let next = acc + s.revenue
            if scaled >= acc && scaled < next { return s }
            acc = next
        }
        return nil
    }

    private var selectedSlice: ServiceRevenueSlice? {
        guard let a = selectedAngle else { return nil }
        return slice(at: a)
    }

    var body: some View {
        let donutSize: CGFloat = 230

        Chart(chartData, id: \.id) { item in
            SectorMark(
                angle: .value("Revenue", item.revenue * progress),
                innerRadius: .ratio(0.68),
                outerRadius: .ratio(1.0),
                angularInset: 1.0
            )
            .foregroundStyle(by: .value("Service", item.title))
            .opacity(selectedSlice == nil || selectedSlice?.service == item.service ? 1.0 : 0.3)
            .cornerRadius(2)
        }
        .chartLegend(position: .bottom, alignment: .center, spacing: 12)
        .chartPlotStyle { plot in
            plot.frame(width: donutSize, height: donutSize)
        }
        .frame(maxWidth: .infinity)
        .chartBackground { chartProxy in
            GeometryReader { geo in
                if let anchor = chartProxy.plotFrame {
                    let f = geo[anchor]
                    VStack(spacing: 4) {
                        Text(formatRUB(selectedSlice?.revenue ?? totalRevenue))
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.9), value: selectedSlice?.revenue ?? totalRevenue)

                        ZStack {
                            Text(selectedSlice?.title ?? "Всего")
                                .font(.system(size: 12, weight: .light))
                                .foregroundStyle(.secondary)
                                .id(selectedSlice?.id.rawValue ?? "total")
                                .transition(Twirl())
                        }
                        .animation(.bouncy(duration: 0.5), value: selectedSlice?.id)
                    }
                    .position(x: f.midX, y: f.midY)
                }
            }
        }
        .chartAngleSelection(value: $selectedAngle)
        .onAppear {
            progress = animateOnAppear ? 0 : 1
            if animateOnAppear {
                withAnimation(.easeInOut(duration: 1.1)) {
                    progress = 1
                }
            }
        }
    }
}

// MARK: - Breakdown list
struct ServiceBreakdownList: View {
    let data: [ServiceRevenueSlice]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(data, id: \.id) { s in
                HStack {
                    Text(s.title)
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    Text("\(s.count)x")
                        .font(.system(size: 10, weight: .light))
                        .foregroundStyle(.secondary)
                    Text(formatRUB(s.revenue))
                        .font(.system(size: 14, weight: .semibold))
                }
            }
        }
    }
}

// MARK: - Composite view (Card + Chart + List)
struct MonthlyServiceAnalyticsView: View {
    var isLoading: Bool = false
    var scope: OrderScope = .all

    @State private var month: Date = Date()

    private var data: [ServiceRevenueSlice] {
        Analytics.revenueByService(
            orders: OrderModel.mocks,
            in: month,
            scope: scope
        )
    }

    private var total: Double { data.reduce(0) { $0 + $1.revenue } }

    var body: some View {
        Card {
            CardHeader(icon: "chart.pie.fill", title: "Траты по услугам")

            if isLoading {
                ActivitySummaryPlaceholder()
                    .padding(.top)
            } else {
                VStack(alignment: .leading, spacing: 20) {
                    ServiceDonutChart(data: data)
                    MonthPicker(month: $month, maxMonth: Date())
                    ServiceBreakdownList(data: data)

                    HStack {
                        Text("Итого:")
                            .font(.system(size: 14, weight: .semibold))
                        Spacer()
                        Text(formatRUB(total))
                            .font(.system(size: 16, weight: .bold))
                    }
                }
                .padding(.top, 10)
            }
        }
        .skeleton(isRedacted: isLoading)
        .allowsHitTesting(!isLoading)
    }

    // MARK: - Placeholder (Skeleton)
    @ViewBuilder
    private func ActivitySummaryPlaceholder() -> some View {
        let donutSize: CGFloat = 220

        HStack(alignment: .top, spacing: 40) {
            VStack(spacing: 24) {
                Circle()
                    .stroke(Color.primary.opacity(0.08), lineWidth: 30)
                    .frame(width: donutSize, height: donutSize)
                    .overlay {
                        VStack(spacing: 10) {
                            placeholderBar(width: 90, height: 24, alpha: 0.15)
                            placeholderBar(width: 70, height: 10, alpha: 0.1, corner: 6)
                        }
                    }

                VStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { _ in
                        placeholderMetricRow(labelWidth: .random(in: 120...160), valueWidth: .random(in: 60...80))
                    }
                }
            }
        }
        .padding(.top, 10)
        .redacted(reason: .placeholder)
    }

    private func placeholderMetricRow(labelWidth: CGFloat, valueWidth: CGFloat) -> some View {
        HStack(spacing: 8) {
            placeholderBar(width: labelWidth, height: 10, alpha: 0.10)
            Spacer()
            placeholderBar(width: valueWidth, height: 14, alpha: 0.16)
        }
    }

    private func placeholderBar(width: CGFloat, height: CGFloat, alpha: CGFloat, corner: CGFloat = 3) -> some View {
        RoundedRectangle(cornerRadius: corner, style: .continuous)
            .fill(Color.primary.opacity(alpha))
            .frame(width: width, height: height)
    }
}

// MARK: - RUB plain formatter
private func formatRUB(_ value: Double) -> String {
    let f = NumberFormatter()
    f.numberStyle = .decimal
    f.maximumFractionDigits = 2
    f.minimumFractionDigits = 0
    f.groupingSeparator = Locale.current.groupingSeparator
    f.decimalSeparator = Locale.current.decimalSeparator
    let text = f.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    return "\(text) р."
}

// MARK: - Preview
#Preview("Services Revenue – Donut") {
    ScrollView {
        VStack(spacing: 40) {
            MonthlyServiceAnalyticsView(isLoading: true)
            MonthlyServiceAnalyticsView(scope: .ownerOnly("user_01"))
        }
    }
    .padding()
    .background(Color.themeBG)
    .ignoresSafeArea()
}
