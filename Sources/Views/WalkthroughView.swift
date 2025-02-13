import SwiftUI

struct WalkthroughView: View {
    @AppStorage("hasCompletedWalkthrough") private var hasCompletedWalkthrough = false
    @AppStorage("name") private var name = ""
    @AppStorage("age") private var age = 18
    @AppStorage("sex") private var sex = "Male"
    @AppStorage("heightFeet") private var heightFeet = 5
    @AppStorage("heightInches") private var heightInches = 11
    @AppStorage("bodyWeight") private var bodyWeight = 172.0
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            VStack {
                if currentPage == 0 {
                    WelcomePage(onNext: { currentPage += 1 })
                } else if currentPage == 1 {
                    BasicInfoPage(name: $name, age: $age, onNext: { currentPage += 1 })
                } else if currentPage == 2 {
                    BodyMetricsPage(sex: $sex, heightFeet: $heightFeet, heightInches: $heightInches, bodyWeight: $bodyWeight, onNext: { currentPage += 1 })
                } else if currentPage == 3 {
                    SummaryPage(name: name, onComplete: {
                        hasCompletedWalkthrough = true
                    })
                }
            }
        }
    }
}

struct WelcomePage: View {
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "figure.strengthtraining.traditional.circle")
                .font(.system(size: 150))
                .foregroundColor(.blue)
            
            Text("Welcome to Home Gym!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Your AI Home Gym Trainer")
                .font(.title2)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(icon: "chart.bar.fill",
                          text: "Track your workouts and progress")
                FeatureRow(icon: "flame.fill",
                          text: "Calculate calories burned")
                FeatureRow(icon: "person.fill",
                          text: "Personalized workout recommendations")
            }
            .padding(.top, 30)
            
            Button(action: onNext) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: 80)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 40)
        }
        .padding()
    }
}

struct BasicInfoPage: View {
    @Binding var name: String
    @Binding var age: Int
    @State private var showAlert = false
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 25) {
            Text("Let's get to know you")
                .font(.title)
                .fontWeight(.bold)
            
            Text("We'll use this information to personalize your experience")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading) {
                    Text("What's your name?")
                        .fontWeight(.medium)
                    TextField("Enter your name", text: $name)
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading) {
                    Text("How old are you?")
                        .fontWeight(.medium)
                    TextField("Age", value: $age, formatter: NumberFormatter())
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                }
            }
            .padding(.top, 30)
            
            Button(action: {
                if name.isEmpty || age <= 0 {
                    showAlert = true
                } else {
                    onNext()
                }
            }) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: 80)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 40)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Invalid Input"), message: Text("Please enter a valid name and age."), dismissButton: .default(Text("OK")))
            }
        }
        .padding()
    }
}

struct BodyMetricsPage: View {
    @Binding var sex: String
    @Binding var heightFeet: Int
    @Binding var heightInches: Int
    @Binding var bodyWeight: Double
    @State private var showAlert = false
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 25) {
            Text("Body Metrics")
                .font(.title)
                .fontWeight(.bold)
            
            Text("We'll use this to calculate your daily calorie needs and recommend appropriate exercises")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 20) {
                Picker("Biological Sex", selection: $sex) {
                    Text("Male").tag("Male")
                    Text("Female").tag("Female")
                    Text("Other").tag("Other")
                }
                .pickerStyle(.segmented)
                
                VStack(alignment: .leading) {
                    Text("Height")
                        .fontWeight(.medium)
                    HStack {
                        TextField("Feet", value: $heightFeet, formatter: NumberFormatter())
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                        Text("ft")
                        TextField("Inches", value: $heightInches, formatter: NumberFormatter())
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                        Text("in")
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Weight")
                        .fontWeight(.medium)
                    HStack {
                        TextField("Weight", value: $bodyWeight, formatter: NumberFormatter())
                            .textFieldStyle(.roundedBorder)
                        Text("lbs")
                    }
                }
            }
            .padding(.top, 30)
            
            Button(action: {
                if heightFeet <= 0 || heightInches < 0 || bodyWeight <= 0 {
                    showAlert = true
                } else {
                    onNext()
                }
            }) {
                Text("Next")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: 80)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 40)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Invalid Input"), message: Text("Please enter valid height and weight."), dismissButton: .default(Text("OK")))
            }
        }
        .padding()
    }
}

struct SummaryPage: View {
    let name: String
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("You're all set, \(name)!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Get ready to start your fitness journey with personalized workouts and tracking.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: onComplete) {
                Text("Start Your Journey")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: 180)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 40)
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title2)
            Text(text)
                .foregroundColor(.primary)
        }
    }
}
