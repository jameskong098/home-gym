import SwiftUI

@main
struct HomeGymApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            TabMenus()
        }
    }
}
