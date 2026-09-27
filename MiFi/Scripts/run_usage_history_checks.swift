import Foundation

@main
enum UsageHistoryChecks {
    static func main() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        let day = Date(timeIntervalSince1970: 1_700_000_000)

        let first = UsageHistory.ingest(cumulativeBytes: 1_000, at: day, previousCumulative: 400, daily: [:], calendar: cal)
        assert(first.newBaseline == 1_000)
        assert(first.daily[UsageHistory.dayKey(for: day, calendar: cal)] == 600)

        let rollover = UsageHistory.ingest(cumulativeBytes: 50, at: day, previousCumulative: 9_000, daily: ["2023-11-01": 100], calendar: cal)
        assert(rollover.newBaseline == 50)
        assert(rollover.daily["2023-11-01"] == 100)

        let baselineOnly = UsageHistory.ingest(cumulativeBytes: 5_000, at: day, previousCumulative: nil, daily: [:], calendar: cal)
        assert(baselineOnly.newBaseline == 5_000)
        assert(baselineOnly.daily.isEmpty)

        print("UsageHistory checks passed")
    }
}
