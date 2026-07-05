import SwiftUI

struct RefreshRatePicker: View {
    let label: String
    @Binding var interval: Int

    private let intervals: [(label: String, minutes: Int)] = [
        ("5 minutes", 5),
        ("15 minutes", 15),
        ("30 minutes", 30),
        ("1 hour", 60),
        ("6 hours", 360)
    ]

    var body: some View {
        Picker(label, selection: $interval) {
            ForEach(intervals, id: \.minutes) { option in
                Text(option.label).tag(option.minutes)
            }
        }
    }
}
