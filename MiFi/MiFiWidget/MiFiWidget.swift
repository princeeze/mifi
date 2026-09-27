import SwiftUI
import WidgetKit

struct MiFiEntry: TimelineEntry {
    let date: Date
    let model: MiFiDisplayModel?
}

struct MiFiProvider: TimelineProvider {
    func placeholder(in context: Context) -> MiFiEntry {
        MiFiEntry(date: Date(), model: .preview)
    }

    func getSnapshot(in context: Context, completion: @escaping (MiFiEntry) -> Void) {
        Task {
            let model = await MiFiRefresh.refresh(forceNetwork: !context.isPreview)
            completion(MiFiEntry(date: Date(), model: model ?? .preview))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MiFiEntry>) -> Void) {
        Task {
            let model = await MiFiRefresh.refresh(forceNetwork: true)
            let entry = MiFiEntry(date: Date(), model: model)
            let next = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
            let retry = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
            let policy: TimelineReloadPolicy = model == nil ? .after(retry) : .after(next)
            completion(Timeline(entries: [entry], policy: policy))
        }
    }
}

struct MiFiWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: MiFiEntry

    var body: some View {
        if let model = entry.model {
            Group {
                switch family {
                case .systemSmall:
                    smallLayout(model)
                default:
                    VStack(alignment: .leading, spacing: 0) {
                        StatusView(model: model, showRestart: false)
                        HStack {
                            Spacer()
                            Button(intent: RestartMiFiIntent()) {
                                Text("Restart")
                                    .font(.caption.weight(.medium))
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
            .containerBackground(.fill.tertiary, for: .widget)
        } else {
            ContentUnavailableView("MiFi Unavailable", systemImage: "wifi.exclamationmark")
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }

    @ViewBuilder
    private func smallLayout(_ model: MiFiDisplayModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("MiFi")
                    .font(.headline)
                Spacer()
                Text("\(model.status.batteryPercentage)%")
                    .font(.caption.weight(.semibold))
                    .monospacedDigit()
            }
            Text(ByteFormat.string(model.todayBytes))
                .font(.title3.weight(.semibold))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text("Today")
                .font(.caption2)
                .foregroundStyle(.secondary)
            miniChart(model)
        }
    }

    private func miniChart(_ model: MiFiDisplayModel) -> some View {
        let maxBytes = max(model.lastSevenDays.map(\.bytes).max() ?? 1, 1)
        return HStack(alignment: .bottom, spacing: 3) {
            ForEach(Array(model.lastSevenDays.enumerated()), id: \.offset) { index, entry in
                let isToday = index == model.lastSevenDays.count - 1
                let height = max(3, CGFloat(entry.bytes) / CGFloat(maxBytes) * 28)
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(isToday ? Color.accentColor : Color.secondary.opacity(0.35))
                    .frame(height: height)
            }
        }
        .frame(maxHeight: 32)
    }
}

struct MiFiWidget: Widget {
    let kind: String = "MiFiWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MiFiProvider()) { entry in
            MiFiWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("MiFi")
        .description("Battery, daily data usage, and connection status.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
