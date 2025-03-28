/*
  Audio.swift
  Home Gym

  Created by James Deming Kong
  Part of Swift Student Challenge 2025

  This utility provides audio playback functionality for the app,
  handling sound effects and feedback using AVFoundation framework.
*/

import SwiftUI
import AVFoundation

@MainActor
struct Audio {
    private static var audioPlayer: AVAudioPlayer?
    
    static func playSound(_ soundName: String, extension: String ) {
        if let soundURL = Bundle.main.url(forResource: soundName, withExtension: "caf") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.play()
            } catch {
                print("Failed to play sound: \(error.localizedDescription)")
            }
        } else {
            print("Sound file not found")
        }
    }
}
