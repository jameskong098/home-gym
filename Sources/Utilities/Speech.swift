/*
  Speech.swift
  Home Gym

  Created by James Deming Kong
  Part of Swift Student Challenge 2025

  This utility provides text-to-speech functionality for the app,
  handling voice feedback using AVFoundation's speech synthesis.
*/

import SwiftUI
import AVFoundation

@MainActor
struct Speech {
    private static let speechSynthesizer = AVSpeechSynthesizer()

    static func preWarmSpeechSynthesizer() {
        Task { @MainActor in
            let utterance = AVSpeechUtterance(string: " ")
            utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_male_en-US_compact")
            utterance.volume = 0 
            speechSynthesizer.speak(utterance)
        }
    }

    static func speak(_ message: String) {
        Task { @MainActor in
            let utterance = AVSpeechUtterance(string: message)
            utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_male_en-US_compact")
            speechSynthesizer.speak(utterance)
        }
    }
}
