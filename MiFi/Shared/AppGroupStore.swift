import Foundation

enum AppGroupStore {
    static let suiteName = "group.com.mifi.shared"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    private enum Key {
        static let lastCumulativeBytes = "lastCumulativeBytes"
        static let dailyUsageJSON = "dailyUsageJSON"
        static let cachedStatusJSON = "cachedStatusJSON"
        static let cachedAt = "cachedAt"
        static let restartPauseUntil = "restartPauseUntil"
    }

    static var restartPauseUntil: Date? {
        get {
            guard let t = defaults?.double(forKey: Key.restartPauseUntil), t > 0 else { return nil }
            return Date(timeIntervalSince1970: t)
        }
        set {
            defaults?.set(newValue?.timeIntervalSince1970 ?? 0, forKey: Key.restartPauseUntil)
        }
    }

    static var isPausedForRestart: Bool {
        guard let until = restartPauseUntil else { return false }
        return Date() < until
    }

    static func markRestartPause(seconds: TimeInterval = 90) {
        restartPauseUntil = Date().addingTimeInterval(seconds)
    }

    static func loadLastCumulativeBytes() -> UInt64? {
        guard let n = defaults?.object(forKey: Key.lastCumulativeBytes) as? NSNumber else { return nil }
        return n.uint64Value
    }

    static func saveLastCumulativeBytes(_ value: UInt64) {
        defaults?.set(NSNumber(value: value), forKey: Key.lastCumulativeBytes)
    }

    static func loadDailyUsage() -> [String: UInt64] {
        guard let json = defaults?.string(forKey: Key.dailyUsageJSON),
              let data = json.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([String: UInt64].self, from: data)
        else { return [:] }
        return decoded
    }

    static func saveDailyUsage(_ usage: [String: UInt64]) {
        guard let data = try? JSONEncoder().encode(usage),
              let json = String(data: data, encoding: .utf8)
        else { return }
        defaults?.set(json, forKey: Key.dailyUsageJSON)
    }

    static func loadCachedStatus() -> (status: MiFiStatus, fetchedAt: Date)? {
        guard let json = defaults?.string(forKey: Key.cachedStatusJSON),
              let data = json.data(using: .utf8),
              let status = try? JSONDecoder().decode(MiFiStatus.self, from: data)
        else { return nil }
        let t = defaults?.double(forKey: Key.cachedAt) ?? 0
        guard t > 0 else { return nil }
        return (status, Date(timeIntervalSince1970: t))
    }

    static func saveCachedStatus(_ status: MiFiStatus) {
        guard let data = try? JSONEncoder().encode(status),
              let json = String(data: data, encoding: .utf8)
        else { return }
        defaults?.set(json, forKey: Key.cachedStatusJSON)
        defaults?.set(Date().timeIntervalSince1970, forKey: Key.cachedAt)
    }
}
