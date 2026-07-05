import Foundation

extension Date {
    public static func diff(from: Date, to: Date) -> Int? {
        let components = Calendar.current.dateComponents([.day], from: from, to: to)
        guard let days = components.day else { return nil }
        return abs(days)
    }

    public static func round(from: Date, strategy: RoundingStrategy) -> Date? {
        switch strategy {
            case .previousQuarterHour:
                return roundToPreviousQuarterHour(from: from)
            case .nextQuarterHour:
                return roundToNextQuarterHour(from: from)
            case .previousHour:
                return roundToPreviousHour(from: from)
            case .nextHour:
                return roundToNextHour(from: from)
            case .lastDayChange:
                return roundToLastDayChange(from: from)
            case .lastUTCDayChange:
                return roundToLastUTCDayChange(from: from)
        }
    }

    public static func fromString(_ string: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: string)
    }

    public func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }

    private static func roundToPreviousQuarterHour(from: Date) -> Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: from)
        guard let minute = components.minute else { return nil }
        let remainder = minute % 15
        var adjustedComponents = components
        adjustedComponents.minute = minute - remainder
        adjustedComponents.second = 0
        return calendar.date(from: adjustedComponents)
    }

    private static func roundToPreviousHour(from: Date) -> Date? {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: from)
        guard components.hour != nil else { return nil }
        components.minute = 0
        components.second = 0
        return calendar.date(from: components)
    }

    private static func roundToLastDayChange(from: Date) -> Date? {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: from)
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone(abbreviation: "UTC")
        return calendar.date(from: components)
    }

    private static func roundToLastUTCDayChange(from: Date) -> Date? {
        roundToLastDayChange(from: from)
    }

    private static func roundToNextQuarterHour(from date: Date) -> Date? {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        guard let minute = components.minute else { return nil }
        let remainder = minute % 15
        let minutesToAdd = 15 - remainder
        components.minute = minute + minutesToAdd
        components.second = 0
        if let minutes = components.minute, minutes >= 60 {
            components.minute = minutes - 60
            components.hour = (components.hour ?? 0) + 1
            if components.hour == 24 {
                components.hour = 0
                if let nextDay = calendar.date(byAdding: .day, value: 1, to: date) {
                    components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: nextDay)
                }
            }
        }
        return calendar.date(from: components)
    }

    private static func roundToNextHour(from date: Date) -> Date? {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        components.hour = (components.hour ?? 0) + 1
        components.minute = 0
        components.second = 0
        if components.hour == 24 {
            components.hour = 0
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: date) {
                let nextComponents = calendar.dateComponents([.year, .month, .day], from: nextDay)
                components.year = nextComponents.year
                components.month = nextComponents.month
                components.day = nextComponents.day
            }
        }
        return calendar.date(from: components)
    }
}
