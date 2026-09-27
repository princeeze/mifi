import XCTest

import MiFiCore

final class UsageHistoryTests: XCTestCase {
    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        return cal
    }

    func testIngestAddsDeltaToToday() {
        let day = Date(timeIntervalSince1970: 1_700_000_000)
        let (daily, baseline) = UsageHistory.ingest(
            cumulativeBytes: 1_000,
            at: day,
            previousCumulative: 400,
            daily: [:],
            calendar: calendar
        )
        XCTAssertEqual(baseline, 1_000)
        XCTAssertEqual(daily[UsageHistory.dayKey(for: day, calendar: calendar)], 600)
    }

    func testIngestMonthRolloverDoesNotGoNegative() {
        let day = Date(timeIntervalSince1970: 1_700_000_000)
        let (daily, baseline) = UsageHistory.ingest(
            cumulativeBytes: 50,
            at: day,
            previousCumulative: 9_000,
            daily: ["2023-11-01": 100],
            calendar: calendar
        )
        XCTAssertEqual(baseline, 50)
        XCTAssertEqual(daily["2023-11-01"], 100)
        XCTAssertNil(daily[UsageHistory.dayKey(for: day, calendar: calendar)])
    }

    func testIngestFirstSampleSetsBaselineOnly() {
        let day = Date(timeIntervalSince1970: 1_700_000_000)
        let (daily, baseline) = UsageHistory.ingest(
            cumulativeBytes: 5_000,
            at: day,
            previousCumulative: nil,
            daily: [:],
            calendar: calendar
        )
        XCTAssertEqual(baseline, 5_000)
        XCTAssertTrue(daily.isEmpty)
    }

    func testLastSevenDaysOrder() {
        let end = calendar.date(from: DateComponents(year: 2024, month: 3, day: 10))!
        let daily: [String: UInt64] = [
            "2024-03-04": 1,
            "2024-03-10": 9,
        ]
        let week = UsageHistory.lastSevenDays(from: daily, endingOn: end, calendar: calendar)
        XCTAssertEqual(week.count, 7)
        XCTAssertEqual(week.first?.bytes, 1)
        XCTAssertEqual(week.last?.bytes, 9)
    }
}
