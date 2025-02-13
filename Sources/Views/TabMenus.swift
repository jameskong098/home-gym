import SwiftUI

struct TabMenus: View {
    @Binding var selectedTab: Int
    @Binding var navPath: [String]
    @AppStorage("themePreference") private var themePreference = "dark"
    @State private var editMode = false
    @State private var activityCount = 0
    @State private var showingFilterMenu = false
    @StateObject private var filterModel = WorkoutFilterModel()
    @State private var workouts: [WorkoutData] = []

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
                           showingFilterMenu = true
                       }) {
                           Image(systemName: "line.3.horizontal.decrease.circle")
                               .font(.headline)
                               .frame(width: 50) 
                       }
                       .popover(isPresented: $showingFilterMenu, arrowEdge: .top) {
                           FilterMenu(filterModel: filterModel, workouts: workouts)
                               .frame(idealWidth: 400, idealHeight: UIDevice.current.userInterfaceIdiom == .pad ? 800 : nil)
                       }
                       Button(action: {
                            withAnimation() {
                                editMode.toggle()
                            }
                       }) {
                           Text(editMode ? "Done" : "Edit")
                               .font(.headline)
                               .frame(width: 50)
                       }
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
                    WorkoutView(selectedTab: $selectedTab, navPath: $navPath)
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
                    ActivityView(
                        editMode: $editMode,
                        onActivitiesChange: { count in
                            activityCount = count
                            if count == 0 {
                                editMode = false
                            }
                        },
                        onWorkoutsUpdate: { updatedWorkouts in
                            workouts = updatedWorkouts
                        },
                        filterModel: filterModel
                    )
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
        if UIDevice.current.userInterfaceIdiom == .pad {
            return "Home Gym"
        }
        
        switch selectedTab {
        case 0:
            return "Home Gym"
        case 1:
            return "Workout"
        case 2:
            return "Activity"
        case 3:
            return "Settings"
        default:
            return ""
        }
    }
}
