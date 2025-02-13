import SwiftUI

@main
struct HomeGymApp: App {
    @State private var navPath: [String] = []
    @State private var selectedTab: Int = 0
    @AppStorage("hasCompletedWalkthrough") private var hasCompletedWalkthrough = false

    var body: some Scene {
        WindowGroup {
            
            if hasCompletedWalkthrough {
            
                NavigationStack(path: $navPath) {
                    TabMenus(selectedTab: $selectedTab, navPath: $navPath)
                    .navigationDestination(for: String.self) { pathValue in
                        if pathValue == "Activity" {
                            TabMenus(selectedTab: $selectedTab, navPath: $navPath)
                            .navigationBarBackButtonHidden(true)
                            .navigationBarHidden(true)
                        }
                        else if pathValue.starts(with: "ExerciseSummaryView") {
                            let components = pathValue.split(separator: "|").map { String($0) }
                            if components.count == 4 {
                                let exerciseName = components[1]
                                let repCount = Int(components[2]) ?? 0
                                let elapsedTime = TimeInterval(components[3]) ?? 0
                                ExerciseSummaryView(selectedTab: $selectedTab, navPath: $navPath, exerciseName: exerciseName, repCount: repCount, elapsedTime: elapsedTime)
                            }
                        }
                    }
                }
             
            } else {
                WalkthroughView()
            }
        }
    }
}
