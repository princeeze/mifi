import Foundation

public enum UsageHistory {
    static let retentionDays = 14
    private static let dayKeyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone.current
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    public static func dayKey(for date: Date, calendar: Calendar = .current) -> String {
        let start = calendar.startOfDay(for: date)
        return dayKeyFormatter.string(from: start)
    }

    /// Records a new month-to-date total; returns updated daily map and the new baseline cumulative value.
    public static func ingest(
        cumulativeBytes: UInt64,
        at date: Date,
        previousCumulative: UInt64?,
        daily: [String: UInt64],
        calendar: Calendar = .current
    ) -> (daily: [String: UInt64], newBaseline: UInt64) {
        var map = daily
        let key = dayKey(for: date, calendar: calendar)

        if let prev = previousCumulative {
            if cumulativeBytes >= prev {
                let delta = cumulativeBytes - prev
                map[key, default: 0] += delta
            }
            // Month rollover: cumulative dropped — start fresh baseline, no negative day.
        }

        map = prune(map, relativeTo: date, calendar: calendar)
        return (map, cumulativeBytes)
    }

    public static func lastSevenDays(from daily: [String: UInt64], endingOn date: Date, calendar: Calendar = .current) -> [(day: Date, bytes: UInt64)] {
        let start = calendar.startOfDay(for: date)
        return (0 ..< 7).reversed().map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: start)!
            let key = dayKey(for: day, calendar: calendar)
            return (day, daily[key] ?? 0)
        }
    }

    static func prune(_ daily: [String: UInt64], relativeTo date: Date, calendar: Calendar = .current) -> [String: UInt64] {
        let cutoff = calendar.date(byAdding: .day, value: -(retentionDays - 1), to: calendar.startOfDay(for: date))!
        let cutoffKey = dayKey(for: cutoff, calendar: calendar)
        return daily.filter { $0.key >= cutoffKey }
    }
}
