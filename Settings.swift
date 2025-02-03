import SwiftUI

struct Settings: View {
    @AppStorage("enableSoundCues") private var enableSoundCues = true
    @AppStorage("enableVoice") private var enableVoice = true
    @AppStorage("showBodyTrackingPoints") private var showBodyTrackingPoints = true
    @AppStorage("showBodyTrackingLabels") private var showBodyTrackingLabels = false
    @AppStorage("showBodyTrackingLines") private var showBodyTrackingLines = true
    @AppStorage("themePreference") private var themePreference = "system"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Audio")
                    .font(.headline)
                    .padding(.top)

                VStack(alignment: .center, spacing: 10) {
                    Toggle("Enable Sound Cues", isOn: $enableSoundCues).padding(.horizontal)
                    Divider()
                    Toggle("Enable Voice", isOn: $enableVoice).padding(.horizontal)
                }
                .padding()
                .background(Color(UIColor { traitCollection in
                    if traitCollection.userInterfaceStyle == .dark {
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
                    Toggle("Show Body Tracking Points", isOn: $showBodyTrackingPoints).padding(.horizontal)
                    Divider()
                    Toggle("Show Body Tracking Labels", isOn: $showBodyTrackingLabels).padding(.horizontal)
                    Divider()
                    Toggle("Show Body Tracking Lines", isOn: $showBodyTrackingLines).padding(.horizontal)
                }
                .padding()
                .background(Color(UIColor { traitCollection in
                    if traitCollection.userInterfaceStyle == .dark {
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
}
