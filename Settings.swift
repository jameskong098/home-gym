import SwiftUI

struct Settings: View {
    @AppStorage("enableTutorials") private var enableTutorials = true
    @AppStorage("enableAutomaticTimer") private var enableAutomaticTimer = true
    @AppStorage("useWideAngleCamera") private var useWideAngleCamera = false
    @AppStorage("enableSoundCues") private var enableSoundCues = true
    @AppStorage("enableVoice") private var enableVoice = true
    @AppStorage("showBodyTrackingPoints") private var showBodyTrackingPoints = true
    @AppStorage("showBodyTrackingLabels") private var showBodyTrackingLabels = false
    @AppStorage("showBodyTrackingLines") private var showBodyTrackingLines = true
    @AppStorage("themePreference") private var themePreference = "system"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("General")
                    .font(.headline)
                    .padding(.top)

                VStack(alignment: .center, spacing: 10) {
                    Toggle("Show Tutorials", isOn: $enableTutorials)
                        .padding(.horizontal)
                        .tint(Theme.toggleSwitchColor)
                        .onChange(of: enableTutorials) { _ in
                            triggerHapticFeedback()
                        }
                    Divider()
                    Toggle("Automatic Timer", isOn: $enableAutomaticTimer)
                        .padding(.horizontal)
                        .tint(Theme.toggleSwitchColor)
                        .onChange(of: enableAutomaticTimer) { _ in
                            triggerHapticFeedback()
                        }
                    if ARCameraViewController.deviceSupportsUltraWide() {
                        Divider()
                        Toggle("Use Ultra Wide Camera", isOn: $useWideAngleCamera)
                            .padding(.horizontal)
                            .tint(Theme.toggleSwitchColor)
                            .onChange(of: enableTutorials) { _ in
                                triggerHapticFeedback()
                            }
                    }
                }
                .padding()
                .background(Color(UIColor { traitCollection in
                    if (traitCollection.userInterfaceStyle == .dark) {
                        return Theme.settingsSectionBackgroundColorDark
                    } else {
                        return Theme.settingsSectionBackgroundColorLight
                    }
                }))
                .cornerRadius(25)

                Text("Audio")
                    .font(.headline)
                    .padding(.top)

                VStack(alignment: .center, spacing: 10) {
                    Toggle("Enable Sound Cues", isOn: $enableSoundCues)
                        .padding(.horizontal)
                        .tint(Theme.toggleSwitchColor)
                        .onChange(of: enableSoundCues) { _ in
                            triggerHapticFeedback()
                        }
                    Divider()
                    Toggle("Enable Voice", isOn: $enableVoice)
                        .padding(.horizontal)
                        .tint(Theme.toggleSwitchColor)
                        .onChange(of: enableVoice) { _ in
                            triggerHapticFeedback()
                        }
                }
                .padding()
                .background(Color(UIColor { traitCollection in
                    if (traitCollection.userInterfaceStyle == .dark) {
                        return Theme.settingsSectionBackgroundColorDark
                    } else {
                        return Theme.settingsSectionBackgroundColorLight
                    }
                }))
                .cornerRadius(25)

                Text("Body Tracking")
                    .font(.headline)
                    .padding(.top)

                VStack(alignment: .center, spacing: 10) {
                    Toggle("Show Body Tracking Points", isOn: $showBodyTrackingPoints)
                        .padding(.horizontal)
                        .tint(Theme.toggleSwitchColor)
                        .onChange(of: showBodyTrackingPoints) { _ in
                            triggerHapticFeedback()
                        }
                    Divider()
                    Toggle("Show Body Tracking Labels", isOn: $showBodyTrackingLabels)
                        .padding(.horizontal)
                        .tint(Theme.toggleSwitchColor)
                        .onChange(of: showBodyTrackingLabels) { _ in
                            triggerHapticFeedback()
                        }
                    Divider()
                    Toggle("Show Body Tracking Lines", isOn: $showBodyTrackingLines)
                        .padding(.horizontal)
                        .tint(Theme.toggleSwitchColor)
                        .onChange(of: showBodyTrackingLines) { _ in
                            triggerHapticFeedback()
                        }
                }
                .padding()
                .background(Color(UIColor { traitCollection in
                    if (traitCollection.userInterfaceStyle == .dark) {
                        return Theme.settingsSectionBackgroundColorDark
                    } else {
                        return Theme.settingsSectionBackgroundColorLight
                    }
                }))
                .cornerRadius(25)

                Text("Theme")
                    .font(.headline)
                    .padding(.top)
                
                ThemeSelectionButton()
                    .padding(.horizontal)
                
                Text("Selecting system will use your device's system settings.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding()
        }
    }

    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
