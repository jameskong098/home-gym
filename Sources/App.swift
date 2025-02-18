import SwiftUI
import TipKit

@main
struct HomeGymApp: App {
    @AppStorage("hasCompletedWalkthrough") private var hasCompletedWalkthrough = false

    init() {
        configureTips()
    }

    var body: some Scene {
        WindowGroup {
            if hasCompletedWalkthrough {
                MainContentView()
            } else {
                WalkthroughView()
            }
        }
    }

    private func configureTips() {
        do {
            if #available(iOS 17.0, *) {
                try Tips.configure()
                print("Tips configured successfully")
            } else {
                print("Tips not available on this version of iOS")
                // Fallback on earlier versions
            }
            print("Tips configured successfully")
        } catch {
            print("Error configuring tips: \(error)")
        }
    }
}
