import SwiftUI

struct Settings: View {
    @AppStorage("enableTutorials") private var enableTutorials = true
    @AppStorage("enableAutomaticTimer") private var enableAutomaticTimer = true
    @AppStorage("useWideAngleCamera") private var useWideAngleCamera = true
    @AppStorage("enableSoundCues") private var enableSoundCues = true
    @AppStorage("enableVoice") private var enableVoice = true
    @AppStorage("showBodyTrackingPoints") private var showBodyTrackingPoints = true
    @AppStorage("showBodyTrackingLabels") private var showBodyTrackingLabels = false
    @AppStorage("showBodyTrackingLines") private var showBodyTrackingLines = true
    @AppStorage("themePreference") private var themePreference = "dark"
    @AppStorage("name") private var name = ""
    @AppStorage("age") private var age = 18
    @AppStorage("sex") private var sex = "Male"
    @AppStorage("heightFeet") private var heightFeet = 5
    @AppStorage("heightInches") private var heightInches = 11
    @AppStorage("bodyWeight") private var bodyWeight = 172.0
    

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
                    if CameraViewController.deviceSupportsUltraWide() {
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

                Text("Personal Information")
                    .font(.headline)
                    .padding(.top)

                VStack(alignment: .center, spacing: 10) {
                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("Enter your name", text: $name)
                            .padding(.horizontal)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    Divider()
                    HStack {
                        Text("Age")
                        Spacer()
                        TextField("Enter your age", value: $age, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .padding(.horizontal)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    Divider()
                    HStack {
                        Text("Gender")
                        Spacer()
                        Picker("Select your gender", selection: $sex) {
                            Text("Male").tag("Male")
                            Text("Female").tag("Female")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                    }
                    Divider()
                    HStack {
                        Text("Height")
                        Spacer()
                        TextField("Feet", value: $heightFeet, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .padding(.horizontal)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Text("ft")
                        TextField("Inches", value: $heightInches, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .padding(.horizontal)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Text("in")
                    }
                    Divider()
                    HStack {
                        Text("Body Weight (lb)")
                        Spacer()
                        TextField("Body Weight", value: $bodyWeight, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .padding(.horizontal)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
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
