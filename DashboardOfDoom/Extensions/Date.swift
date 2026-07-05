import Foundation

extension Date {
    private func absoluteString(fmtStr: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = fmtStr
        return String(format: "%@", formatter.string(from: self))
    }

    func relativeString() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return String(format: "%@", formatter.string(for: self) ?? "<Unknown>")
    }

    func absoluteString() -> String {
        return self.absoluteString(fmtStr: "yyyy-MM-dd HH:mm")
    }

    static func absoluteString(date: Date?) -> String {
        guard let date else { return "<Unknown>" }
        return date.absoluteString()
    }

    func string() -> String {
        return self.absoluteString(fmtStr: "yyyy-MM-dd HH:mm")
    }

    func timeString() -> String {
        return self.absoluteString(fmtStr: "HH:mm")
    }
}
