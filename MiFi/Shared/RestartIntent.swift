import AppIntents
import Foundation

public struct RestartMiFiIntent: AppIntent {
    public static var title: LocalizedStringResource = "Restart MiFi"
    public static var description = IntentDescription("Restarts the mobile hotspot.")
    public static var openAppWhenRun: Bool = false

    public init() {}

    public func perform() async throws -> some IntentResult {
        try await requestConfirmation(
            dialog: IntentDialog("Restart the MiFi? All connected devices will disconnect briefly.")
        )

        guard let client = CredentialsStore.makeClient() else {
            throw NSError(domain: "MiFi", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing credentials"])
        }

        try await client.reboot()
        AppGroupStore.markRestartPause()
        return .result()
    }
}
