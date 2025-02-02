import SwiftUI

struct TabMenus: View {
    @State private var selectedTab = 1

    var body: some View {
        VStack {
            Text(currentTabName)
                .font(.title)
                .fontWeight(.bold)
                .padding()

            TabView(selection: $selectedTab) {
                ProgressTracker()
                    .tabItem {
                        Label("Progress", systemImage: "chart.bar")
                    }
                    .tag(0)

                Exercise()
                    .tabItem {
                        Label("Workout", systemImage: "figure.walk")
                    }
                    .tag(1)

                Settings()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
                    .tag(2)
            }
        }
    }

    private var currentTabName: String {
        switch selectedTab {
        case 0:
            return "Progress"
        case 1:
            return "Workout"
        case 2:
            return "Settings"
        default:
            return ""
        }
    }
}
