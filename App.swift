import SwiftUI

@main
struct HomeGymApp: App {
    @State private var navPath: [String] = []
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navPath) {
                TabMenus(selectedTab: .constant(1), navPath: $navPath)
                .navigationDestination(for: String.self) { pathValue in
                    if pathValue == "Activity" {
                        ExecuteCode(navPath: $navPath)
                        TabMenus(selectedTab: .constant(2), navPath: $navPath)
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                    }
                    if pathValue.starts(with: "ExerciseSummaryView") {
                        let components = pathValue.split(separator: "|").map { String($0) }
                        if components.count == 4 {
                            let exerciseName = components[1]
                            let repCount = Int(components[2]) ?? 0
                            let elapsedTime = TimeInterval(components[3]) ?? 0
                            ExerciseSummaryView(selectedTab: .constant(1), navPath: $navPath, exerciseName: exerciseName, repCount: repCount, elapsedTime: elapsedTime)
                        }
                    }
                }
            }
        }
    }
    
}

struct ExecuteCode: View {
    @Binding var navPath: [String]
    
    var body: some View {
        EmptyView()
            .onAppear {
                navPath.removeAll()
            }
    }
}
