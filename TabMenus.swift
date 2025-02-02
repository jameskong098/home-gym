import SwiftUI

struct TabMenus: View {
    @State private var selectedTab = 1

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        
        appearance.backgroundColor = UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 0.7)
            } else {
                return UIColor.white
            }
        }
        
        UITabBar.appearance().standardAppearance = appearance
        
        // For iOS 15 and later, update the scrollEdgeAppearance as well
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some View {
        NavigationView {
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
        }.navigationViewStyle(StackNavigationViewStyle())
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
