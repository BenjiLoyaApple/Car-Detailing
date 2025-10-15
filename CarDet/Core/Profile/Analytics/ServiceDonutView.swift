//
//  ServiceDonutView.swift
//  CarDet
//
//  Created by Assistant on 15.10.2025.
//

import SwiftUI
import Charts

private final class LocalPriceFormatter {
    static let shared = LocalPriceFormatter()
    private let nf: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = .current
        return f
    }()
    func string(_ value: Double) -> String {
        nf.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }
}

// MARK: - Donut

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
        let donutSize: CGFloat = 250

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
            .accessibilityLabel(item.title)
            .accessibilityValue(LocalPriceFormatter.shared.string(item.revenue))
        }
        // Легенда справа, в одну колонку — дайте Chart достаточно ширины
       // .chartLegend(position: .bottom, alignment: .center, spacing: 14)
        .chartLegend(.hidden)
        .chartPlotStyle { plot in
            // Фиксируем размер только для пончика (plot), не всего Chart
            plot.frame(width: donutSize, height: donutSize)
        }
        // УБРАНО жёсткое ограничение ширины всего Chart:
       //  .frame(width: donutSize)
        // Дадим занять доступную ширину карточки, чтобы справа поместилась колонка легенды
        .frame(maxWidth: .infinity, alignment: .center)
        .chartBackground { chartProxy in
            GeometryReader { geo in
                if let anchor = chartProxy.plotFrame {
                    let f = geo[anchor]
                    VStack(spacing: 4) {
                        Text(LocalPriceFormatter.shared.string(selectedSlice?.revenue ?? totalRevenue))
                            .font(.system(size: 19, weight: .bold))
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.9), value: selectedSlice?.revenue ?? totalRevenue)

                        Text(selectedSlice?.title ?? "Всего")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(.secondary)
                            .id(selectedSlice?.id ?? DetailingService.exteriorWash) // стабилизируем transition
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.25), value: selectedSlice?.id)
                    }
                    .position(x: f.midX, y: f.midY)
                }
            }
        }
        .chartAngleSelection(value: $selectedAngle)
        .onAppear {
            progress = animateOnAppear ? 0 : 1
            if animateOnAppear {
                withAnimation(.easeInOut(duration: 1.1)) { progress = 1 }
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
                    
                    Text(LocalPriceFormatter.shared.string(s.revenue))
                        .font(.system(size: 14, weight: .semibold))
                    
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Breakdown by service")
    }
}

// MARK: - Composite view (карточка)
struct MonthlyServiceAnalyticsView: View {
    var isLoading: Bool = false
    typealias ComputeSlices = (Date) -> [ServiceRevenueSlice]
    let compute: ComputeSlices

    @State private var month: Date = Date()

    private func monthStart(_ date: Date) -> Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: date)
        return cal.date(from: comps) ?? date
    }

    private var data: [ServiceRevenueSlice] { compute(monthStart(month)) }
    private var total: Double { data.reduce(0) { $0 + $1.revenue } }

    var body: some View {
        Card {
            CardHeader(icon: "chart.pie.fill", title: "Services revenue")

            if isLoading {
                ActivitySummaryPlaceholder()
                    .padding(.top)
            } else {
                VStack(alignment: .leading, spacing: 25) {
                    ServiceDonutChart(data: data)
                    
                    MonthPicker(month: $month, minMonth: nil, maxMonth: Date())

                    ServiceBreakdownList(data: data)
                    
                    HStack {
                        Text("Итого:")
                            .font(.system(size: 14, weight: .semibold))
                        
                        Spacer()
                        
                        Text(LocalPriceFormatter.shared.string(total))
                            .font(.system(size: 16, weight: .bold))
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
        let donutSize: CGFloat = 220

        HStack(alignment: .top, spacing: 40) {
            VStack(alignment: .center, spacing: 30) {
                Circle()
                    .stroke(Color.primary.opacity(0.08), lineWidth: 30)
                    .frame(width: donutSize, height: donutSize)
                    .overlay {
                        VStack(spacing: 10) {
                            placeholderBar(width: 110, height: 32, alpha: 0.15)
                            placeholderBar(width: 90, height: 12, alpha: 0.1, corner: 6)
                        }
                    }
                
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 16)
                        .frame(height: 30)
                        .foregroundStyle(.gray.opacity(0.2))
                        .padding(.vertical, 10)
                        .padding(.bottom, 10)

                    placeholderMetricRow(labelWidth: 152, valueWidth: 80)
                    placeholderMetricRow(labelWidth: 100, valueWidth: 80)
                    placeholderMetricRow(labelWidth: 146, valueWidth: 60)
                    placeholderMetricRow(labelWidth: 124, valueWidth: 80)
                }
            }
            .padding(.leading, 10)
            
            
            
        }
        .padding(.top, 10)
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

// MARK: - Preview
#Preview("Services Donut") {
    VStack(spacing: 40) {
        MonthlyServiceAnalyticsView(isLoading: true) { _ in [] }

        MonthlyServiceAnalyticsView(isLoading: false) { month in
            ServiceAnalytics.revenueByService(
                orders: OrderModel.mocks,
                in: month
            )
        }
    }
    .padding()
    .background(Color.themeBG)
}
