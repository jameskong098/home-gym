import SwiftUI

struct Settings: View {
    @AppStorage("enableSoundCues") private var enableSoundCues = true
    @AppStorage("enableVoice") private var enableVoice = true
    @AppStorage("showBodyTrackingPoints") private var showBodyTrackingPoints = true
    @AppStorage("showBodyTrackingLabels") private var showBodyTrackingLabels = false
    @AppStorage("showBodyTrackingLines") private var showBodyTrackingLines = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Audio")
                        .font(.headline)
                        .padding(.top)

                    Toggle("Enable Sound Cues", isOn: $enableSoundCues).padding(.horizontal)
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
                .cornerRadius(10)
                .shadow(radius: 5)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Body Tracking")
                        .font(.headline)
                        .padding(.top)

                    Toggle("Show Body Tracking Points", isOn: $showBodyTrackingPoints).padding(.horizontal)
                    Toggle("Show Body Tracking Labels", isOn: $showBodyTrackingLabels).padding(.horizontal)
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
                .cornerRadius(10)
                .shadow(radius: 5)

                Spacer()
            }
            .padding()
        }
    }
}
