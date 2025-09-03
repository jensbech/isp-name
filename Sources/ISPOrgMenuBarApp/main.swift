import SwiftUI
import AppKit
import ServiceManagement

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
    }
}

struct MenuBarView: View {
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @AppStorage("launchAtLogin") private var launchAtLogin = false

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

            Divider()

            Toggle("Launch at Login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { newValue in
                    setLaunchAtLogin(enabled: newValue)
                }
        }
        .padding()
        .frame(width: 280)
        .onAppear { 
            networkMonitor.startMonitoring()
            if #available(macOS 13.0, *) {
                launchAtLogin = SMAppService.mainApp.status == .enabled
            }
        }
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
                .onTapGesture {
                    copyToClipboard(value)
                }
                .help("Click to copy")
        }
    }

    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    private func setLaunchAtLogin(enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to \(enabled ? "enable" : "disable") launch at login: \(error)")
                DispatchQueue.main.async {
                    launchAtLogin = !enabled
                }
            }
        }
    }
}

final class NetworkMonitor: ObservableObject {
    @Published var currentOrg: String = "Loading..."
    @Published var currentIP: String = "Loading..."
    @Published var city: String = ""; @Published var country: String = ""
    @Published var lastUpdated: String = ""
    
    var shortOrg: String {
        if currentOrg.starts(with: "AS") {
            let parts = currentOrg.components(separatedBy: " ")
            if parts.count > 1 {
                return parts.dropFirst().joined(separator: " ")
            }
        }
        return currentOrg
    }

    private var timer: Timer?
    private let refreshInterval: TimeInterval = 60

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
