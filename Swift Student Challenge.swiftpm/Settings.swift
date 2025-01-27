import SwiftUI

struct SettingsScreen: View {
    var body: some View {
        VStack {
            Text("Settings")
                .font(.title)
                .fontWeight(.bold)
                .padding()

            Toggle("Enable Sound Cues", isOn: .constant(true))
                .padding()
            
            Toggle("Show Achievement Alerts", isOn: .constant(true))
                .padding()
            
            Spacer()
        }
        .padding()
    }
}
