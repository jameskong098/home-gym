/*
  Theme.swift
  Home Gym

  Created by James Deming Kong
  Part of Swift Student Challenge 2025

  This utility defines the app's color scheme and theme constants,
  providing consistent styling for both light and dark modes.
*/

import SwiftUI

struct Theme {
    static let headerColorLight = UIColor(white: 0.85, alpha: 1.0)
    static let headerColorDark = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 0.7)

    static let footerItemColorLight = UIColor(red: 70/255, green: 70/255, blue: 70/255, alpha: 1.0)
    static let footerItemColorDark = UIColor(white: 0.85, alpha: 1.0)
    static let footerBackgroundColorLight = UIColor(white: 0.85, alpha: 1.0)
    static let footerBackgroundColorDark = UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 0.7)
    static let footerAccentColor = Color.blue

    static let mainContentBackgroundColorLight = UIColor(white: 0.95, alpha: 1.0)
    static let mainContentBackgroundColorDark = UIColor.black
    
    static let calendarHighlightOutlineLight = Color.black
    static let calendarHighlightOutlineDark = Color.white
    
    static let exerciseListItemIconColorLight = UIColor.white
    static let exerciseListItemIconColorDark = UIColor.black
    static let exerciseListItemTextColorLight = UIColor.black
    static let exerciseListItemTextColorDark = UIColor.white
    static let exerciseListItemBackgroundColorLight = UIColor(red: 0/255, green: 100/255, blue: 255/255, alpha: 1.0)
    static let exerciseListItemBackgroundColorDark = UIColor.white
    static let exerciseListBackgroundColorLight = UIColor(red: 214/255, green: 228/255, blue: 255/255, alpha: 1.0)
    static let exerciseListBackgroundColorDark = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 0.7)
    
    static let settingsSectionBackgroundColorLight = UIColor.white
    static let settingsSectionBackgroundColorDark = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 0.7)
    static let settingsThemeTextColorLight = UIColor.black
    static let settingsThemeTextColorDark = UIColor.white
    static let toggleSwitchColor = Color.blue
    static let settingsInfoSaveButton = Color.blue
    
    static let hudBackgroundColor = Color.black.opacity(0.4)
}
