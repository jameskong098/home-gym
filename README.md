# 🏋️ Home Gym - iOS/iPadOS Fitness App
Developed by James Deming Kong for Apple's **2025 Swift Student Challenge**

**Jan 2025** - **Feb 2025**

## 📌 General Overview

**Home Gym** is an **exercise tracking app** designed to make working out at home more engaging and effective. By leveraging advanced body tracking technology and computer vision, **Home Gym** allows you to monitor your exercises in real-time, ensuring proper form and providing feedback on your progress. The app features comprehensive workout logging and analytics, allowing users to track their fitness journey through detailed exercise metrics, progress visualization, and performance trends. Supporting a variety of exercises, the app includes features like automatic rep counting, personalized goal setting, workout history management, and achievement rewards to keep you motivated.

## 🎯 Feature Overview

### 🔍 **Real-time Exercise Tracking**

- Utilizes **Vision Framework** for **body tracking** and **form analysis**
- Option to show/hide body tracking points, labels, and lines

### 🏃 Supports multiple exercises:

- Jumping Jacks
- High Knees
- Basic Squats
- Wall Squats
- Lunges
- Standing Side Leg Raises
- Pilates Sit-Ups Hybrid
- Planks
- Push-Ups
- Bicep Curls - Simultaneous
- Lateral Raises
- Front Raises

### 🔢 **Automatic Rep Counting & Goal Setting**

- Tracks **reps and sets automatically** based on movement detection
- Allows users to set **daily and weekly fitness goals** based on reps, duration, or calories burned
- Provides **progress updates** and tracks long-term performance

### 🏆 **Achievement System**

- Unlock **badges** based on workout streaks, rep milestones, duration milestones, and calorie milestones
- Keeps users motivated with real-time **progress tracking**

### 🗣️ **Voice Guidance & Feedback**

- Voice assistant gives **real-time verbal cues** for:
    - Correct form
    - Countdown timer and rep counts
    - Encouragement during workouts
- Option to enable/disable voice cues.

## 🔍 In-Depth Overview
### 🎛️ **Customizable Settings**

- ⚙️ **General Settings**
  - 📚 Enable/Disable Tutorials
  - ⏱️ Enable/Disable Countdown Timer
  - 📹 Use Ultra Wide Camera (on supported devices)
  - 🔢 Enable/Disable Voice Count
  - 🗣️ Enable/Disable Motivational Voice

- 👤 **Personal Information**
  - Name
  - Age
  - Sex
  - Height (ft/in)
  - Weight (lb)

- 🎯 **Custom Goals**
  - Daily Goals
    - Reps
    - Duration (minutes)
    - Calories
  - Weekly Goals
    - Reps
    - Duration (minutes)
    - Calories
  - Monthly Goals
    - Reps
    - Duration (minutes)
    - Calories
  - Quick reset to default values

- 🏃 **Body Tracking Options**
  - 🔴 Show/Hide Body Tracking Points
  - 🔠 Show/Hide Body Tracking Labels
  - 🔵 Show/Hide Body Tracking Lines

- 🎨 **Theme Selection**
  - Light Mode
  - Dark Mode
  - System Default

### 📊 **Activity Logging System**

- 📝 **Workout History**
  - Log and track all completed workouts
  - View detailed exercise metrics:
    - Rep counts
    - Duration
    - Calories burned
    - Weight used (if applicable)
  - Filter workouts by:
    - Exercise type
    - Date range
    - Performance metrics

- ✏️ **Edit Capabilities**
  - Modify workout details after completion
  - Adjust rep counts and duration
  - Add/edit weight used
  - Delete individual workout entries

- 📈 **Progress Analytics**
  - View workout trends over time
  - Track improvement across exercises
  - Monitor personal records
  - Analyze workout frequency and consistency

### 📈 **Progress Tracking Interface**

- 📅 **Interactive Calendar View**
  - Visual representation of workout days
  - Select dates to view detailed workout information
  - Track workout consistency and streaks

- 🎯 **Goal Progress Visualization**
  - Monitor progress across three timeframes:
    - Daily goals and achievements
    - Weekly performance tracking
    - Monthly milestone progress
  - Track multiple metrics:
    - Total reps completed
    - Workout duration (minutes)
    - Calories burned

- 🏃 **Streak Tracking**
  - Display current workout streak
  - Record and showcase longest streak achieved
  - Motivational messages to maintain consistency

- 📊 **Progress Charts**
  - Circular progress indicators for each goal
  - Color-coded metrics for easy visualization:
    - Reps (Green)
    - Duration (Blue)
    - Calories (Orange)
  - Adaptive layout for different device orientations

## 📱 How It Works

1.  **Launch the app** and grant camera access
2.  **Select an exercise** (e.g., push-ups, squats, lunges)
3.  **Start tracking** – The app detects movements and **automatically counts reps**
4.  **Get voice and visual feedback** on form and progress
5.  **Achieve fitness goals** by tracking daily/weekly performance
6.  **Edit workout summaries** to adjust rep counts, time, or weight
7.  **Filter workouts** in the activity view to focus on specific exercises or time periods

## 🔧 Technologies Used

- **SwiftUI** – Handles building the app UI and interactions
- **UIKit** - Handles wrapping views and triggering haptics
- **Vision** – Handles real-time body pose tracking
- **AVCaptureSession** – Handles camera input for motion tracking
- **AVFoundation** - Handles audio playback for sound effects
- **CALayer** – Displays overlays for joints and movement guidance
- **AVSpeechSynthesizer** – Provides real-time voice feedback
- **Charts** - For visual analytics and statistics
- **TipKit** - Provides tip info to explain features

**Sound Effects** – [Material Design Sound Resources](https://m2.material.io/design/sound/sound-resources.html#) ([CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/legalcode))

**App Lunge Figure Icon** – [Warrior Pose Right Vector Icon Design Vectors by Vecteezy](https://www.vecteezy.com/vector-art/20194203-warrior-pose-right-vector-icon-design)

## 🚀 Future Enhancements

- **More Exercise Modes**: Additional workout types and tracking methods
- **AI-based Form Correction**: AI-powered suggestions for better posture
- **AI-based Insights**: AI-powered analysis on workout progress
- **Social Features**: Compete with friends and share progress