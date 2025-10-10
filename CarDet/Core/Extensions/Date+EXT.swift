//
//  Date+EXT.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 10/8/24.
//

import Foundation

extension Date {
    var shortHuman: String {
        formatted(.dateTime.year().month(.abbreviated).day())
    }
}

extension Date {
    func addingTimeInterval(days: Int = 0, hours: Int = 0, minutes: Int = 0) -> Date {
        let dayInterval = TimeInterval(days * 24 * 60 * 60)
        let hourInterval = TimeInterval(hours * 60 * 60)
        let minuteInterval = TimeInterval(minutes * 60)
        return self.addingTimeInterval(dayInterval + hourInterval + minuteInterval)
    }
}


extension Date {
    /// Дата  (на главной странице таски)
    var formattedMonthYear: String {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "MMMM,  YYYY"
            return formatter.string(from: self)
        }
    //USAGE:  -     Text(Date().formattedMonthYear)
    
    var formattedMonthDay: String {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "MMMM, dd"
            return formatter.string(from: self)
        }
    //USAGE:  -     Text(Date().formattedMonthDay)
    
    /// Формат: "Monday, 14 December"
      var formattedFullStyle: String {
          let formatter = DateFormatter()
          formatter.locale = Locale(identifier: "en_US")
          formatter.dateFormat = "EEEE, dd MMMM"
          return formatter.string(from: self)
      }
      // USAGE: Text(task.startDate.formattedFullStyle)
    
    /// Дата начала и конца (при создании таски)
    func formattedTaskStyle() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US") // или "ru_RU"
        formatter.dateFormat = "d MMMM, HH:mm" // HH = 24-часовой формат
        return formatter.string(from: self)
    }
    //USAGE:  -     Text(startDate.formattedTaskStyle())
    
    
    ///  Дата начала и конца (в карточке таски)
    static func formattedTimeRange(from start: Date, to end: Date?) -> String {
        let end = end ?? start.addingTimeInterval(3600) // fallback: +1 час

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.locale = Locale(identifier: "en_US")

        let startTime = timeFormatter.string(from: start)
        let endTime = timeFormatter.string(from: end)

        return "\(startTime) - \(endTime)"
    }
    
    //USAGE:  -    Text(Date.formattedTimeRange(from: start, to: end))
}


extension Date {
    struct Day: Identifiable, Hashable {
        var date: Date
        var id: Date { date }       // ✅ стабильный id
    }

    static func startOfWeek(for date: Date = .now) -> Date {
        let calendar = Calendar.current
        if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) {
            return weekInterval.start
        }
        return date
    }

    static var fullDayHours: [Int] { Array(0..<24) }

    static var currentWeek: [Day] {
        let calendar = Calendar.current
        // можно weekOfYear — тогда понедельник всегда будет началом недели
        guard let firstWeekDay = calendar.dateInterval(of: .weekOfYear, for: .now)?.start else {
            return []
        }
        return (0..<7)
            .compactMap { calendar.date(byAdding: .day, value: $0, to: firstWeekDay) }
            .map { Day(date: $0) }
    }

    /// CONVERT DATE TO STRING IN THE GIVEN FORMAT
    func string(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = format
        return formatter.string(from: self)
    }

    /// Check if both the dates are same
    func isSame(_ date: Date?) -> Bool {
        guard let date else { return false }
        return Calendar.current.isDate(self, inSameDayAs: date)
    }
}

