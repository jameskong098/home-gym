import SwiftUI
import TipKit

struct CalendarTip: Tip {
    var id = UUID()
    var title: Text {
        Text("Track Your Progress")
    }
    
    var message: Text? {
        Text("Tap a date to see your workout stats for that day.")
    }
    
    var image: Image? {
        Image(systemName: "calendar")
    }
}

struct GoalsTip: Tip {
    var id = UUID()
    var title: Text {
        Text("Set Your Goals")
    }
    
    var message: Text? {
        Text("Choose a goal type and track your daily, weekly, and monthly progress.")
    }
    
    var image: Image? {
        Image(systemName: "target")
    }
}

struct AchievementsTip: Tip {
    var id = UUID()
    var title: Text {
        Text("Earn Achievements")
    }
    
    var message: Text? {
        Text("Unlock achievements by reaching milestones in your fitness journey.")
    }
    
    var image: Image? {
        Image(systemName: "trophy")
    }
}
