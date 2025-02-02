import SwiftUI

struct TabMenus: View {
    @State private var selectedTab = 1

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return Theme.footerBackgroundColorDark
            } else {
                return Theme.footerBackgroundColorLight
            }
        }
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return Theme.footerItemColorDark
            } else {
                return Theme.footerItemColorLight
            }
        }
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return Theme.footerItemColorDark
            } else {
                return Theme.footerItemColorLight
            }
        }]
                
        // For iOS 15 and later, update the scrollEdgeAppearance as well
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text(currentTabName)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.vertical, 15)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color(UIColor { traitCollection in
                        if traitCollection.userInterfaceStyle == .dark {
                            return Theme.headerColorDark
                        } else {
                            return Theme.headerColorLight
                        }
                    }))
                TabView(selection: $selectedTab) {
                    ZStack {
                        Color(UIColor { traitCollection in
                            if traitCollection.userInterfaceStyle == .dark {
                                return Theme.mainContentBackgroundColorDark
                            } else {
                                return Theme.mainContentBackgroundColorLight
                            }
                        })
                            .ignoresSafeArea(edges: [.top, .leading, .trailing])
                        ProgressTracker()
                    }
                        .tabItem {
                            Label("Progress", systemImage: "chart.bar")
                        }
                        .tag(0)
                    ZStack {
                        Color(UIColor { traitCollection in
                            if traitCollection.userInterfaceStyle == .dark {
                                return Theme.mainContentBackgroundColorDark
                            } else {
                                return Theme.mainContentBackgroundColorLight
                            }
                        })
                            .ignoresSafeArea(edges: [.top, .leading, .trailing])
                        Exercise()
                    }
                        .tabItem {
                            Label("Workout", systemImage: "figure.walk")
                        }
                        .tag(1)
                    ZStack {
                        Color(UIColor { traitCollection in
                            if traitCollection.userInterfaceStyle == .dark {
                                return Theme.mainContentBackgroundColorDark
                            } else {
                                return Theme.mainContentBackgroundColorLight
                            }
                        })
                            .ignoresSafeArea(edges: [.top, .leading, .trailing])
                        Settings()
                    }
                        .tabItem {
                            Label("Settings", systemImage: "gearshape")
                        }
                        .tag(2)
                }.accentColor(Theme.footerAccentColor)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
