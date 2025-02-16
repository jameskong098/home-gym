import SwiftUI

struct MainContentView: View {
    @State private var navPath: [String] = []
    @State private var selectedTab: Int = 0

    var body: some View {
        NavigationStack(path: $navPath) {
            TabMenus(selectedTab: $selectedTab, navPath: $navPath)
                .navigationDestination(for: String.self) { pathValue in
                    if pathValue == "Activity" {
                        TabMenus(selectedTab: $selectedTab, navPath: $navPath)
                            .navigationBarBackButtonHidden(true)
                            .navigationBarHidden(true)
                    }
                }
        }
    }
}

struct WalkthroughView: View {
    @AppStorage("hasCompletedWalkthrough") private var hasCompletedWalkthrough = false
    @AppStorage("name") private var name = ""
    @AppStorage("age") private var age = 0
    @AppStorage("sex") private var sex = ""
    @AppStorage("heightFeet") private var heightFeet = 0
    @AppStorage("heightInches") private var heightInches = 0
    @AppStorage("bodyWeight") private var bodyWeight = 0.0
    @State private var currentPage = 0
    @State private var slideOffset: CGFloat = 0
    @State private var walkthroughCompleted = false

    var body: some View {
        if walkthroughCompleted {
            MainContentView()
        } else {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                
                VStack {
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            WelcomePage(onNext: {
                                withAnimation(.spring()) {
                                    slideOffset = -geometry.size.width
                                    currentPage = 1
                                }
                            })
                            .frame(width: geometry.size.width)
                            
                            BasicInfoPage(name: $name, age: $age, onNext: {
                                withAnimation(.spring()) {
                                    slideOffset = -geometry.size.width * 2
                                    currentPage = 2
                                }
                            })
                            .frame(width: geometry.size.width)
                            
                            BodyMetricsPage(sex: $sex, heightFeet: $heightFeet, heightInches: $heightInches, bodyWeight: $bodyWeight, onNext: {
                                withAnimation(.spring()) {
                                    slideOffset = -geometry.size.width * 3
                                    currentPage = 3
                                }
                            })
                            .frame(width: geometry.size.width)
                            
                            SummaryPage(name: name, onComplete: {
                                withAnimation(.spring()) {
                                    hasCompletedWalkthrough = true
                                    walkthroughCompleted = true
                                }
                            })
                            .frame(width: geometry.size.width)
                        }
                        .offset(x: slideOffset)
                    }
                    .background(
                        Color(UIColor { traitCollection in
                            if traitCollection.userInterfaceStyle == .dark {
                                return Theme.footerBackgroundColorDark
                            } else {
                                return Theme.footerBackgroundColorLight
                            }
                        })
                    )
                    .cornerRadius(20)
                    .frame(maxWidth: 660, maxHeight: 650)
                    HStack(spacing: 12) {
                        ForEach(0..<4) { index in
                            Circle()
                                .fill(currentPage >= index ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: 11, height: 11)
                                .scaleEffect(currentPage == index ? 1.2 : 1.0)
                                .animation(.spring(), value: currentPage)
                        }
                    }
                    .padding(.top, 40)
                }
            }
        }
    }
}

struct WelcomePage: View {
    let onNext: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            let isPhone = UIDevice.current.userInterfaceIdiom == .phone
            
            VStack(spacing: 30) {
                Image(systemName: "figure.strengthtraining.traditional.circle")
                    .font(.system(size: isPhone ? 100 : 150))
                    .foregroundColor(.blue)
                
                Text("Welcome to Home Gym!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .minimumScaleFactor(isPhone ? 0.7 : 1)
                
                Text("Your AI Home Gym Trainer")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(isPhone ? 0.7 : 1)
                
                VStack(alignment: .leading, spacing: 20) {
                    FeatureRow(icon: "person.fill",
                               text: "AI Coach provides personalized insights and analysis",
                               isPhone: isPhone)
                    FeatureRow(icon: "eye.square.fill",
                               text: "Automatically track your exercises using machine learning vision",
                               isPhone: isPhone)
                    FeatureRow(icon: "chart.bar.fill",
                               text: "Monitor and analyze your workout progress",
                               isPhone: isPhone)
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
            .padding(40)
            .frame(maxWidth: 660, maxHeight: 650)
        }
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
                    Text("What's your first name?")
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
        .padding(40)
        .frame(maxWidth: 660, maxHeight: 650)
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
                if sex.isEmpty || heightFeet <= 0 || heightInches < 0 || bodyWeight <= 0 {
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
                Alert(title: Text("Invalid Input"), message: Text("Please enter valid height, weight, and select your sex."), dismissButton: .default(Text("OK")))
            }
        }
        .padding(40)
        .frame(maxWidth: 660, maxHeight: 650)
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
        .padding(40)
        .frame(maxWidth: 660, maxHeight: 650)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    let isPhone: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title2)
            Text(text)
                .foregroundColor(.primary)
                .lineLimit(isPhone ? 2 : 1)
                .minimumScaleFactor(isPhone ? 0.7 : 1)
        }
    }
}
