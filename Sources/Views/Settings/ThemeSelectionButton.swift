/*
  ThemeSelectionButton.swift
  Home Gym

  Created by James Deming Kong
  Part of Swift Student Challenge 2025

  This view implements a custom segmented control for theme selection,
  allowing users to switch between system, dark, and light appearances
  with smooth animations and haptic feedback.
*/

import SwiftUI

struct ThemeSelectionButton: View {
    @AppStorage("themePreference") private var themePreference = "system"
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                HStack(spacing: 0) {
                    Color.clear.frame(width: geometry.size.width / 3)
                    Color.clear.frame(width: geometry.size.width / 3)
                    Color.clear.frame(width: geometry.size.width / 3)
                }
                .frame(height: 50)
                .background(Color(UIColor { traitCollection in
                    if traitCollection.userInterfaceStyle == .dark {
                        return Theme.settingsSectionBackgroundColorDark
                    } else {
                        return Theme.settingsSectionBackgroundColorLight
                    }
                }))
                .cornerRadius(10)
                
                Color.blue
                    .frame(width: geometry.size.width / 3, height: 50)
                    .cornerRadius(10)
                    .offset(x: highlightOffset(for: themePreference, width: geometry.size.width))
                    .animation(.easeInOut, value: themePreference)
                
                HStack(spacing: 0) {
                    themeOptionButton(title: "System", isSelected: themePreference == "system")
                    Divider()
                    themeOptionButton(title: "Dark", isSelected: themePreference == "dark")
                    Divider()
                    themeOptionButton(title: "Light", isSelected: themePreference == "light")
                }
                .frame(height: 50)
            }
        }
        .frame(height: 50)
    }
    
    private func highlightOffset(for preference: String, width: CGFloat) -> CGFloat {
        switch preference {
        case "system":
            return 0
        case "dark":
            return width / 3
        case "light":
            return 2 * width / 3
        default:
            return 0
        }
    }
    
    private func themeOptionButton(title: String, isSelected: Bool) -> some View {
        Button(action: {
            withAnimation(.easeInOut) {
                themePreference = title.lowercased()
                triggerHapticFeedback()
            }
        }) {
            HStack {
                Text(title)
                    .foregroundColor(isSelected ? .white : Color(UIColor { traitCollection in
                        if traitCollection.userInterfaceStyle == .dark {
                            return Theme.settingsThemeTextColorDark
                        } else {
                            return Theme.settingsThemeTextColorLight
                        }
                    }))
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
