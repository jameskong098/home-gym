import SwiftUI

struct TabMenus: View {
    @Binding var selectedTab: Int
    @Binding var navPath: [String]
    @AppStorage("themePreference") private var themePreference = "system"
    @State private var editMode = false
    @State private var activityCount = 0

    init(selectedTab: Binding<Int>, navPath: Binding<[String]>) {
        self._selectedTab = selectedTab
        self._navPath = navPath
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
                
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
               Spacer()
               Text(currentTabName)
                   .font(.title)
                   .fontWeight(.bold)
               Spacer()
           }
           .padding(.vertical, 15)
           .background(
               UIDevice.current.userInterfaceIdiom == .pad ? Color(UIColor { traitCollection in
                   if traitCollection.userInterfaceStyle == .dark {
                       return Theme.mainContentBackgroundColorDark
                   } else {
                       return Theme.mainContentBackgroundColorLight
                   }
               }) : Color(UIColor { traitCollection in
                   if traitCollection.userInterfaceStyle == .dark {
                       return Theme.headerColorDark
                   } else {
                       return Theme.headerColorLight
                   }
               })
           )
           .overlay(
               HStack {
                   Spacer()
                   if selectedTab == 2 && activityCount > 0 {
                       Button(action: {
                           editMode.toggle()
                       }) {
                           Text(editMode ? "Done" : "Edit")
                               .font(.headline)
                               .frame(width: 50)
                       }
                       .padding(.trailing, 15)
                   }
               },
               alignment: .trailing
           )

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
                    Exercise(selectedTab: $selectedTab, navPath: $navPath)
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
                    ActivityView(editMode: $editMode, onActivitiesChange: { count in
                        activityCount = count
                        if count == 0 {
                            editMode = false
                        }
                    })
                }
                    .tabItem {
                        Label("Activity", systemImage: "list.bullet")
                    }
                    .tag(2)
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
                    .tag(3)
            }.accentColor(Theme.footerAccentColor)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(
                    themePreference == "system" ? nil :
                    (themePreference == "light" ? .light : .dark)
                )
    }
    
    private var currentTabName: String {
        switch selectedTab {
        case 0:
            return "Progress"
        case 1:
            return "Home Gym"
        case 2:
            return "Activity"
        case 3:
            return "Settings"
        default:
            return ""
        }
    }
}
