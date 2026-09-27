import SwiftUI

public struct StatusView: View {
    let model: MiFiDisplayModel
    var showRestart: Bool
    var onRestart: (() -> Void)?

    public init(model: MiFiDisplayModel, showRestart: Bool = true, onRestart: (() -> Void)? = nil) {
        self.model = model
        self.showRestart = showRestart
        self.onRestart = onRestart
    }

    private var batteryColor: Color {
        if model.status.batteryPercentage < 20 { return .red }
        if model.status.batteryPercentage < 30 { return .orange }
        return .primary
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header
            usageSection
            chartSection
            footer
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text("MiFi")
                    .font(.headline)
                HStack(spacing: 4) {
                    Circle()
                        .fill(model.status.isConnected ? Color.green : Color.secondary)
                        .frame(width: 6, height: 6)
                    Text(model.status.networkType)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: batterySymbol)
                    .foregroundStyle(batteryColor)
                Text("\(model.status.batteryPercentage)%")
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(batteryColor)
            }
        }
    }

    private var batterySymbol: String {
        let p = model.status.batteryPercentage
        switch p {
        case 0: return "battery.0"
        case 1 ... 25: return "battery.25"
        case 26 ... 50: return "battery.50"
        case 51 ... 75: return "battery.75"
        default: return "battery.100"
        }
    }

    private var usageSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Today")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(ByteFormat.string(model.todayBytes))
                .font(.title2.weight(.semibold))
                .monospacedDigit()
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            Text("Month \(ByteFormat.string(model.status.monthlyTotalBytes))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var chartSection: some View {
        let maxBytes = max(model.lastSevenDays.map(\.bytes).max() ?? 1, 1)
        return HStack(alignment: .bottom, spacing: 6) {
            ForEach(Array(model.lastSevenDays.enumerated()), id: \.offset) { index, entry in
                let isToday = index == model.lastSevenDays.count - 1
                let height = max(4, CGFloat(entry.bytes) / CGFloat(maxBytes) * 44)
                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(isToday ? Color.accentColor : Color.secondary.opacity(0.35))
                        .frame(height: height)
                    Text(shortWeekday(entry.day))
                        .font(.system(size: 9))
                        .foregroundStyle(isToday ? .primary : .secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 60)
    }

    private var footer: some View {
        HStack {
            if model.isStale {
                Text("Offline")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if showRestart, let onRestart {
                Button("Restart", action: onRestart)
                    .buttonStyle(.borderless)
                    .font(.caption.weight(.medium))
            }
        }
    }

    private func shortWeekday(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f.string(from: date)
    }
}

public extension MiFiDisplayModel {
    static var preview: MiFiDisplayModel {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let days = (0 ..< 7).reversed().map { i -> (Date, UInt64) in
            let d = cal.date(byAdding: .day, value: -i, to: today)!
            return (d, UInt64([120, 80, 200, 150, 90, 300, 175][6 - i]) * 1_048_576)
        }
        return MiFiDisplayModel(
            status: MiFiStatus(
                batteryPercentage: 86,
                monthlyRxBytes: 200_000_000_000,
                monthlyTxBytes: 16_000_000_000,
                networkType: "LTE",
                pppStatus: "ppp_connected"
            ),
            fetchedAt: Date(),
            todayBytes: 175 * 1_048_576,
            lastSevenDays: days,
            isStale: false
        )
    }
}
