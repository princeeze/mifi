import SwiftUI

@main
struct MiFiApp: App {
    init() {
        CredentialsStore.seedDefaultsIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            HostView()
                .frame(minWidth: 360, minHeight: 420)
        }
    }
}
