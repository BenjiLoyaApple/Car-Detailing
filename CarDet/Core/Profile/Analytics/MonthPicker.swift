//
//  MonthPicker.swift
//  CarDet
//
//  Created by BenjiLoya on 16.10.2025.
//

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


#Preview {
    MonthPicker(month: .constant(Date()))
        .padding()
}
