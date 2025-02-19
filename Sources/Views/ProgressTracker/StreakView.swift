/*
  StreakView.swift
  Home Gym

  Created by James Deming Kong
  Part of Swift Student Challenge 2025

  This view displays workout streak information with dynamic icons,
  showing current or longest streak counts with visual indicators.
*/

import SwiftUI

struct StreakView: View {
    let value: Int
    let label: String
    
    var body: some View {
        VStack {
            HStack(spacing: 4) {
                Text("\(value)")
                    .font(.title)
                    .bold()
                    .foregroundColor(.orange)
                Image(systemName: label.contains("Current") ? "flame.circle.fill" : "trophy.fill")
                    .foregroundColor(.orange)
            }
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
