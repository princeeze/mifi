import SwiftUI

struct HostView: View {
    @State private var model: MiFiDisplayModel?
    @State private var isLoading = false
    @State private var restartError: String?
    @State private var showRestartConfirm = false

    var body: some View {
        NavigationStack {
        VStack(alignment: .leading, spacing: 0) {
            if let model {
                StatusView(
                    model: model,
                    showRestart: true,
                    onRestart: { showRestartConfirm = true }
                )
                .padding()
            } else {
                ContentUnavailableView {
                    Label("No Data Yet", systemImage: "antenna.radiowaves.left.and.right")
                } description: {
                    Text("Connect to your MiFi Wi‑Fi and tap Refresh.")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task { await refresh() }
                } label: {
                    if isLoading {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text("Refresh")
                    }
                }
                .disabled(isLoading)
            }
        }
        .alert("Restart MiFi?", isPresented: $showRestartConfirm) {
            Button("Restart", role: .destructive) {
                Task { await restart() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("All connected devices will disconnect briefly.")
        }
        .alert("Restart Failed", isPresented: Binding(
            get: { restartError != nil },
            set: { if !$0 { restartError = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(restartError ?? "")
        }
        .task {
            await refresh()
        }
    }

    private func refresh() async {
        isLoading = true
        defer { isLoading = false }
        model = await MiFiRefresh.refresh(forceNetwork: true)
    }

    private func restart() async {
        guard let client = CredentialsStore.makeClient() else {
            restartError = "Missing credentials."
            return
        }
        do {
            try await client.reboot()
            AppGroupStore.markRestartPause()
            try? await Task.sleep(for: .seconds(2))
            await refresh()
        } catch {
            restartError = error.localizedDescription
        }
    }
}
