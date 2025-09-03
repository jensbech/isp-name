import SwiftUI
import AppKit

@main
struct MenuBarOrgApp: App {
    @StateObject private var networkMonitor = NetworkMonitor()
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra(networkMonitor.shortOrg.isEmpty ? "Loading..." : networkMonitor.shortOrg) {
            MenuBarView()
                .environmentObject(networkMonitor)
        }
        .menuBarExtraStyle(.window)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Nothing needed yet
    }
}

struct MenuBarView: View {
    @EnvironmentObject var networkMonitor: NetworkMonitor

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "network")
                    .foregroundColor(.blue)
                Text("Current Organization")
                    .font(.headline)
            }

            Divider()

            VStack(alignment: .leading, spacing: 4) {
                dataRow(label: "ORG", value: networkMonitor.currentOrg)
                dataRow(label: "IP", value: networkMonitor.currentIP)
                dataRow(label: "Location", value: "\(networkMonitor.city), \(networkMonitor.country)")
                dataRow(label: "Updated", value: networkMonitor.lastUpdated)
            }

            Divider()

            HStack {
                Button("Refresh Now") {
                    networkMonitor.fetchIPInfo()
                }
                .keyboardShortcut(.init("r"), modifiers: [])

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
        .padding()
        .frame(width: 280)
        .onAppear { networkMonitor.startMonitoring() }
    }

    @ViewBuilder
    private func dataRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label + ":")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .multilineTextAlignment(.trailing)
                .textSelection(.enabled)
        }
    }
}

final class NetworkMonitor: ObservableObject {
    @Published var currentOrg: String = "Loading..."
    @Published var currentIP: String = "Loading..."
    @Published var city: String = ""; @Published var country: String = ""
    @Published var lastUpdated: String = ""
    
    // Computed property for shortened org name in menu bar
    var shortOrg: String {
        if currentOrg.starts(with: "AS") {
            // Extract just the company name after AS number
            let parts = currentOrg.components(separatedBy: " ")
            if parts.count > 1 {
                return parts.dropFirst().joined(separator: " ")
            }
        }
        return currentOrg
    }

    private var timer: Timer?
    private let refreshInterval: TimeInterval = 60 // seconds

    struct IPInfo: Codable {
        let ip: String
        let city: String
        let region: String
        let country: String
        let loc: String
        let org: String
        let postal: String
        let timezone: String
    }

    func startMonitoring() {
        fetchIPInfo()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            self?.fetchIPInfo()
        }
    }

    func fetchIPInfo() {
        guard let url = URL(string: "https://ipinfo.io/json") else { return }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { self.currentOrg = "Error: \(error.localizedDescription)"; self.updateTimestamp() }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async { self.currentOrg = "No data"; self.updateTimestamp() }
                return
            }
            do {
                let ipInfo = try JSONDecoder().decode(IPInfo.self, from: data)
                DispatchQueue.main.async {
                    self.currentOrg = ipInfo.org
                    self.currentIP = ipInfo.ip
                    self.city = ipInfo.city
                    self.country = ipInfo.country
                    self.updateTimestamp()
                }
            } catch {
                DispatchQueue.main.async { self.currentOrg = "Parse error"; self.updateTimestamp() }
            }
        }
        task.resume()
    }

    private func updateTimestamp() {
        let df = DateFormatter()
        df.timeStyle = .medium
        df.dateStyle = .none
        lastUpdated = df.string(from: Date())
    }

    deinit { timer?.invalidate() }
}
