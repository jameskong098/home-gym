import SwiftUI

struct SettingsScreen: View {
    @AppStorage("enableSoundCues") private var enableSoundCues = true
    @AppStorage("enableVoice") private var enableVoice = true
    @AppStorage("showBodyTrackingPoints") private var showBodyTrackingPoints = true
    @AppStorage("showBodyTrackingLabels") private var showBodyTrackingLabels = false
    @AppStorage("showBodyTrackingLines") private var showBodyTrackingLines = true


    var body: some View {
        VStack {
            Text("Settings")
                .font(.title)
                .fontWeight(.bold)
                .padding()

            Toggle("Enable Sound Cues", isOn: $enableSoundCues).padding()
            
            Toggle("Enable Voice", isOn: $enableVoice).padding()
            
            Toggle("Show Body Tracking Points", isOn: $showBodyTrackingPoints).padding()
            
            Toggle("Show Body Tracking Labels", isOn: $showBodyTrackingLabels).padding()
            
            Toggle("Show Body Tracking Lines", isOn: $showBodyTrackingLines).padding()

            Spacer()
        }
        .padding()
    }
}
