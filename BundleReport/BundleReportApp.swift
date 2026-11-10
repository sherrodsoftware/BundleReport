import Sparkle
import SwiftUI

@main
struct BundleReportApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @StateObject private var catalog = AppCatalog()
    @AppStorage("showUtilityApps") private var showUtilityApps = false
    @AppStorage("showAppleDefaultApps") private var showAppleDefaultApps = true
    @AppStorage("showPersonalApps") private var showPersonalApps = true

    // Started from the app delegate, not here: starting during App init lets
    // Sparkle's permission prompt appear before SwiftUI opens the main window.
    static let updaterController = SPUStandardUpdaterController(
        startingUpdater: false,
        updaterDelegate: nil,
        userDriverDelegate: nil
    )
    private let updateAvailability = UpdateAvailability(updater: updaterController.updater)

    var body: some Scene {
        WindowGroup {
            BundleReportView()
                .environmentObject(catalog)
                .frame(minWidth: 940, minHeight: 620)
        }
        .defaultSize(width: 1_060, height: 720)

        Settings {
            BundleReportSettingsView()
        }

        .commands {
            // Matches the About panel in Version Report: copyright and a
            // link to the Sherrod Software website below the version.
            CommandGroup(replacing: .appInfo) {
                Button("About Bundle Report") {
                    let credits = NSMutableAttributedString()
                    let smallFont = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
                    credits.append(NSAttributedString(
                        string: "© Sherrod Software\n",
                        attributes: [.font: smallFont]
                    ))
                    credits.append(NSAttributedString(
                        string: "www.sherrodsoftware.com",
                        attributes: [
                            .font: smallFont,
                            .link: URL(string: "https://www.sherrodsoftware.com")!
                        ]
                    ))
                    NSApplication.shared.orderFrontStandardAboutPanel(options: [
                        .applicationName: "Bundle Report",
                        .credits: credits
                    ])
                }
            }

            UpdateCommands(
                updater: Self.updaterController.updater,
                availability: updateAvailability
            )

            SidebarCommands()

            CommandGroup(after: .sidebar) {
                Divider()

                Button("Refresh Applications") {
                    catalog.refresh()
                }
                .keyboardShortcut("r", modifiers: .command)
                .disabled(catalog.isScanning)

                Button(showUtilityApps ? "Hide Utilities Apps" : "Show Utilities Apps") {
                    showUtilityApps.toggle()
                }

                Button(showAppleDefaultApps ? "Hide Default Apple Apps" : "Show Default Apple Apps") {
                    showAppleDefaultApps.toggle()
                }

                Button(showPersonalApps ? "Hide Apps in Your Applications Folder" : "Show Apps in Your Applications Folder") {
                    showPersonalApps.toggle()
                }
            }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        DispatchQueue.main.async {
            BundleReportApp.updaterController.startUpdater()
        }
    }
}

enum DetailFieldPreference {
    static let version = "showVersionField"
    static let build = "showBuildField"
    static let bundleIdentifier = "showBundleIdentifierField"
    static let appPath = "showAppPathField"
    static let appIconPath = "showAppIconPathField"
    static let relatedFiles = "showRelatedFilesField"
    static let codeRequirement = "showCodeRequirementField"
    static let signingIdentity = "showSigningIdentityField"
    static let teamIdentifier = "showTeamIdentifierField"
}

private struct BundleReportSettingsView: View {
    @AppStorage(DetailFieldPreference.version) private var showVersion = true
    @AppStorage(DetailFieldPreference.build) private var showBuild = true
    @AppStorage(DetailFieldPreference.bundleIdentifier) private var showBundleIdentifier = true
    @AppStorage(DetailFieldPreference.appPath) private var showAppPath = true
    @AppStorage(DetailFieldPreference.appIconPath) private var showAppIconPath = true
    @AppStorage(DetailFieldPreference.relatedFiles) private var showRelatedFiles = true
    @AppStorage(DetailFieldPreference.codeRequirement) private var showCodeRequirement = true
    @AppStorage(DetailFieldPreference.signingIdentity) private var showSigningIdentity = true
    @AppStorage(DetailFieldPreference.teamIdentifier) private var showTeamIdentifier = true

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle("Version", isOn: $showVersion)
            Toggle("Build", isOn: $showBuild)
            Toggle("Bundle Identifier", isOn: $showBundleIdentifier)
            Toggle("App Path", isOn: $showAppPath)
            Toggle("App Icon Path", isOn: $showAppIconPath)
            Toggle("Code Requirement", isOn: $showCodeRequirement)
            Toggle("Signing Identity", isOn: $showSigningIdentity)
            Toggle("Team ID", isOn: $showTeamIdentifier)
            Toggle("Related Files", isOn: $showRelatedFiles)
        }
        .toggleStyle(.checkbox)
        .padding(24)
        .frame(minWidth: 300)
    }
}
