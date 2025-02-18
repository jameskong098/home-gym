import SwiftUI

struct Settings: View {
    @AppStorage("enableTutorials") private var enableTutorials = true
    @AppStorage("enableCountdownTimer") private var enableCountdownTimer = true
    @AppStorage("useWideAngleCamera") private var useWideAngleCamera = true
    @AppStorage("enableSoundCues") private var enableSoundCues = true
    @AppStorage("enableVoice") private var enableVoice = true
    @AppStorage("showBodyTrackingPoints") private var showBodyTrackingPoints = true
    @AppStorage("showBodyTrackingLabels") private var showBodyTrackingLabels = false
    @AppStorage("showBodyTrackingLines") private var showBodyTrackingLines = true
    @AppStorage("themePreference") private var themePreference = "system"
    @AppStorage("name") private var name = ""
    @AppStorage("age") private var age = 0
    @AppStorage("sex") private var sex = ""
    @AppStorage("heightFeet") private var heightFeet = 0
    @AppStorage("heightInches") private var heightInches = 0
    @AppStorage("bodyWeight") private var bodyWeight = 0.0
    @State private var isEditingPersonalInfo = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(Theme.toggleSwitchColor)
                    Text("General")
                        .font(.headline)
                }
                .padding(.top)

                VStack(alignment: .center, spacing: 10) {
                    Toggle("Show Tutorials", isOn: $enableTutorials)
                        .padding(.horizontal)
                        .tint(Theme.toggleSwitchColor)
                        .onChange(of: enableTutorials) { _ in
                            triggerHapticFeedback()
                        }
                    Divider()
                    Toggle("Enable Countdown Timer", isOn: $enableCountdownTimer)
                        .padding(.horizontal)
                        .tint(Theme.toggleSwitchColor)
                        .onChange(of: enableCountdownTimer) { _ in
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

                HStack {
                    Image(systemName: "speaker.wave.3.fill")
                        .foregroundColor(Theme.toggleSwitchColor)
                    Text("Audio")
                        .font(.headline)
                }
                .padding(.top)

                VStack(alignment: .center, spacing: 10) {
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

                HStack {
                    Image(systemName: "figure.walk")
                        .foregroundColor(Theme.toggleSwitchColor)
                    Text("Body Tracking")
                        .font(.headline)
                }
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
                
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(Theme.toggleSwitchColor)
                    Text("Personal Information")
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        isEditingPersonalInfo.toggle()
                        if !isEditingPersonalInfo {
                            triggerHapticFeedback()
                        }
                    }) {
                        Text(isEditingPersonalInfo ? "Done" : "Edit")
                            .foregroundColor(Theme.toggleSwitchColor)
                    }
                }
                .padding(.top)

                VStack(alignment: .center, spacing: 10) {
                    HStack {
                        Text("Name")
                        Spacer()
                        if isEditingPersonalInfo {
                            TextField("Enter your name", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            Text(name.isEmpty ? "Not set" : name)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Age")
                        Spacer()
                        if isEditingPersonalInfo {
                            TextField("Enter your age", value: $age, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            Text(age == 0 ? "Not set" : "\(age)")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Sex")
                        Spacer()
                        if isEditingPersonalInfo {
                            Picker("Select your sex", selection: $sex) {
                                Text("Male").tag("Male")
                                Text("Female").tag("Female")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        } else {
                            Text(sex.isEmpty ? "Not set" : sex)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Height")
                        Spacer()
                        if isEditingPersonalInfo {
                            HStack() {
                                TextField("Feet", value: $heightFeet, formatter: NumberFormatter())
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 50)
                                Text("ft")
                                TextField("Inches", value: $heightInches, formatter: NumberFormatter())
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 50)
                                Text("in")
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Text(heightFeet == 0 && heightInches == 0 ? "Not set" : "\(heightFeet)ft \(heightInches)in")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Body Weight (lb)")
                        Spacer()
                        if isEditingPersonalInfo {
                            TextField("Body Weight", value: $bodyWeight, formatter: NumberFormatter())
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            Text(bodyWeight == 0 ? "Not set" : String(format: "%.1f", bodyWeight))
                                .foregroundColor(.secondary)
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

                HStack {
                    Image(systemName: "paintpalette.fill")
                        .foregroundColor(Theme.toggleSwitchColor)
                    Text("Theme")
                        .font(.headline)
                }
                .padding(.top)
                
                ThemeSelectionButton()
                    .padding(.horizontal)
                
                Text("Selecting system will use your device's system settings.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(Theme.toggleSwitchColor)
                    Text("Credits")
                        .font(.headline)
                }
                .padding(.top)

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Developer")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("James Deming Kong")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Version")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("1.0.0")
                            .font(.body)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Swift Student Challenge 2025")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Made with ❤️ and dedication")
                            .font(.body)
                    }
                    HStack() {
                        Link(destination: URL(string: "https://jameskong098.github.io/")!) {
                            HStack {
                                Image(systemName: "link")
                                Text("Personal Website")
                            }
                            .foregroundColor(Theme.toggleSwitchColor)
                        }
                        .padding(.trailing, 12)
                        Link(destination: URL(string: "https://www.linkedin.com/in/jamesdemingkong/")!) {
                            HStack {
                                Image(systemName: "link")
                                Text("LinkedIn")
                            }
                            .foregroundColor(Theme.toggleSwitchColor)
                        }
                        .padding(.trailing, 12)
                        Link(destination: URL(string: "https://github.com/jameskong098")!) {
                            HStack {
                                Image(systemName: "link")
                                Text("GitHub")
                            }
                            .foregroundColor(Theme.toggleSwitchColor)
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
