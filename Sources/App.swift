import SwiftUI

@main
struct HomeGymApp: App {
    @AppStorage("hasCompletedWalkthrough") private var hasCompletedWalkthrough = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedWalkthrough {
                MainContentView()
            } else {
                WalkthroughView()
            }
        }
    }
}
