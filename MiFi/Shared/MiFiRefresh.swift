import Foundation

public struct MiFiDisplayModel: Sendable {
    public var status: MiFiStatus
    public var fetchedAt: Date
    public var todayBytes: UInt64
    public var lastSevenDays: [(day: Date, bytes: UInt64)]
    public var isStale: Bool

    public init(
        status: MiFiStatus,
        fetchedAt: Date,
        todayBytes: UInt64,
        lastSevenDays: [(day: Date, bytes: UInt64)],
        isStale: Bool
    ) {
        self.status = status
        self.fetchedAt = fetchedAt
        self.todayBytes = todayBytes
        self.lastSevenDays = lastSevenDays
        self.isStale = isStale
    }
}

public enum MiFiRefresh {
    public static func refresh(forceNetwork: Bool = true) async -> MiFiDisplayModel? {
        CredentialsStore.seedDefaultsIfNeeded()
        if AppGroupStore.isPausedForRestart {
            return displayFromCache(markStale: true)
        }

        var status: MiFiStatus?
        var fetchedAt = Date()

        if forceNetwork, let client = CredentialsStore.makeClient() {
            do {
                status = try await client.fetchStatus()
                AppGroupStore.saveCachedStatus(status!)
                fetchedAt = Date()
            } catch {
                status = nil
            }
        }

        if status == nil {
            return displayFromCache(markStale: true)
        }

        return buildDisplay(status: status!, fetchedAt: fetchedAt, isStale: false)
    }

    public static func displayFromCache(markStale: Bool) -> MiFiDisplayModel? {
        guard let cached = AppGroupStore.loadCachedStatus() else { return nil }
        return buildDisplay(status: cached.status, fetchedAt: cached.fetchedAt, isStale: markStale)
    }

    private static func buildDisplay(status: MiFiStatus, fetchedAt: Date, isStale: Bool) -> MiFiDisplayModel {
        let cumulative = status.monthlyTotalBytes
        var daily = AppGroupStore.loadDailyUsage()
        let previous = AppGroupStore.loadLastCumulativeBytes()
        let result = UsageHistory.ingest(
            cumulativeBytes: cumulative,
            at: fetchedAt,
            previousCumulative: previous,
            daily: daily
        )
        daily = result.daily
        AppGroupStore.saveDailyUsage(daily)
        AppGroupStore.saveLastCumulativeBytes(result.newBaseline)

        let todayKey = UsageHistory.dayKey(for: fetchedAt)
        let todayBytes = daily[todayKey] ?? 0
        let week = UsageHistory.lastSevenDays(from: daily, endingOn: fetchedAt)

        return MiFiDisplayModel(
            status: status,
            fetchedAt: fetchedAt,
            todayBytes: todayBytes,
            lastSevenDays: week,
            isStale: isStale
        )
    }
}
