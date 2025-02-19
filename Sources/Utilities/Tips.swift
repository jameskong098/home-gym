/*
  Tips.swift
  Home Gym

  Created by James Deming Kong
  Part of Swift Student Challenge 2025

  This utility provides in-app tips and guidance using TipKit,
  helping users discover and learn app features.
*/

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

struct DayStatsTip: Tip {
    var id = UUID()
    var title: Text {
        Text("View Day Stats")
    }
    
    var message: Text? {
        Text("See your aggregate workout stats for the selected day from the calendar.")
    }
    
    var image: Image? {
        Image(systemName: "chart.bar")
    }
}

struct GoalsTip: Tip {
    var id = UUID()
    var title: Text {
        Text("Set Your Goals")
    }
    
    var message: Text? {
        Text("Choose a goal type and track your daily, weekly, and monthly progress. You can also set custom goals within settings.")
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

struct FavoriteTip: Tip {
    var id = UUID()
    var title: Text {
        Text("Favorite Activities")
    }
    
    var message: Text? {
        Text("Tap the star icon to favorite an activity and access it quickly from the favorites tab")
    }
    
    var image: Image? {
        Image(systemName: "star")
    }
}

struct FilterTip: Tip {
    var id = UUID()
    var title: Text {
        Text("Filter Activities")
    }
    
    var message: Text? {
        Text("Filter by exercise type, duration, and more to find the activities you're looking for.")
    }
    
    var image: Image? {
        Image(systemName: "line.horizontal.3.decrease.circle")
    }
}

struct EditTip: Tip {
    var id = UUID()
    var title: Text {
        Text("Edit Activities")
    }
    
    var message: Text? {
        Text("Turn on edit mode to edit or delete your activities. You can also hold individual activities to access the edit/delete options.")
    }
    
    var image: Image? {
        Image(systemName: "pencil")
    }
}
