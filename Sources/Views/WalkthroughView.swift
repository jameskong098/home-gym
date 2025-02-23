/*
  WalkthroughView.swift
  Home Gym

  Created by James Deming Kong
  Part of Swift Student Challenge 2025

  This view implements the initial onboarding experience with animated pages,
  collecting user information and preferences through an interactive walkthrough
  with progress indicators and responsive layouts. It also contains the main content view workflow,
  where different tabs will be served.
*/

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

struct MainContentViewWrapper: View {
    @AppStorage("automaticallyGenerateDemoData") private var automaticallyGenerateDemoData = true
    @State private var showDemoAlert = false

    var body: some View {
        MainContentView()
            .onAppear {
                if automaticallyGenerateDemoData {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Delay by 1 second since Swift Playgrounds behavior is different for some reason than Xcode App Playgrounds/Sideloaded Previews
                        showDemoAlert = true
                    }
                } 
            }
            .alert("Sample Data Added", isPresented: $showDemoAlert) {
                Button("OK") { }
            } message: {
                Text("Randomized sample data has been added to your activity history for demo purposes. If you would like to generate new data, you can go to the \"Developer Tools\" section within the settings view. You can also turn off randomized sample data generation within the same section.")
            }
    }
}

struct WalkthroughView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("hasCompletedWalkthrough") private var hasCompletedWalkthrough = false
    @AppStorage("name") private var name = ""
    @AppStorage("age") private var age: Int?
    @AppStorage("sex") private var sex = ""
    @AppStorage("heightFeet") private var heightFeet: Int?
    @AppStorage("heightInches") private var heightInches: Int?
    @AppStorage("bodyWeight") private var bodyWeight: Double?
    @State private var currentPage = 0
    @State private var slideOffset: CGFloat = 0
    @State private var isTransitioning = false

    var body: some View {
        ZStack {
            if hasCompletedWalkthrough {
                MainContentViewWrapper()
                    .transition(.opacity.combined(with: .scale))
            }
            
            if !hasCompletedWalkthrough || isTransitioning {
                ZStack {
                    Color(colorScheme == .dark ? Theme.headerColorDark : Theme.mainContentBackgroundColorLight)
                        .ignoresSafeArea()
                    
                    VStack {        
                        Spacer()
                        GeometryReader { geometry in
                            if currentPage > 0 {
                                HStack {
                                    Button(action: {
                                        withAnimation(.spring()) {
                                            slideOffset += geometry.size.width
                                            currentPage -= 1
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: "chevron.left")
                                            Text("Back")
                                        }
                                        .foregroundColor(.blue)
                                        .padding()
                                    }
                                    Spacer()
                                }
                                .zIndex(1)
                            }
                            
                            Spacer()

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
                                    }
                                })
                                .frame(width: geometry.size.width)
                            }
                            .offset(x: slideOffset)
                        }
                        .background(
                            colorScheme == .dark ? Color.black : Color.white
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
                        
                        Spacer()
                    }
                    .padding()
                }
                .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: hasCompletedWalkthrough)
    }
}

struct WelcomePage: View {
    let onNext: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            let isPhone = UIDevice.current.userInterfaceIdiom == .phone
            
            VStack(spacing: 20) {
                if let uiImage = UIImage(named: "AppIcon_NoBG") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: isPhone ? 170 : 200, height: isPhone ? 170 : 200)
                }
                
                Text("Welcome to Home Gym!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .minimumScaleFactor(isPhone ? 0.7 : 1)
                
                Text("Your Smart Personal Fitness Tracker")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(isPhone ? 0.7 : 1)
                
                VStack(alignment: .leading, spacing: 20) {
                    FeatureRow(icon: "figure",
                            text: "Real-time exercise tracking with body pose detection",
                            isPhone: isPhone)
                    FeatureRow(icon: "chart.xyaxis.line",
                            text: "Track progress with detailed activity logs and trends",
                            isPhone: isPhone)
                    FeatureRow(icon: "trophy.circle.fill",
                            text: "Set fitness goals and earn achievement badges",
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
    @Binding var age: Int?
    @State private var showAlert = false
    let onNext: () -> Void
    
    var body: some View {
        ScrollView {
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
                        TextField("Ex. Jimmy", text: $name)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("How old are you?")
                            .fontWeight(.medium)
                        TextField("Ex. 23", value: $age, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                    }
                }
                .padding(.top, 30)
                
                Button(action: {
                    if name.isEmpty || age == nil || age! <= 0 {
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
        .ignoresSafeArea(.keyboard) 
    }
}

struct BodyMetricsPage: View {
    @Binding var sex: String
    @Binding var heightFeet: Int?
    @Binding var heightInches: Int?
    @Binding var bodyWeight: Double?
    @State private var showAlert = false
    let onNext: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Text("Body Metrics")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("We'll use this to calculate your daily calorie needs and recommend appropriate exercises")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Sex")
                            .fontWeight(.medium)
                    Picker("Biological Sex", selection: $sex) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                    }
                    .pickerStyle(.segmented)
                    
                    VStack(alignment: .leading) {
                        Text("Height")
                            .fontWeight(.medium)
                        HStack {
                            TextField("6", value: $heightFeet, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                            Text("ft")
                            TextField("0", value: $heightInches, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                            Text("in")
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Weight")
                            .fontWeight(.medium)
                        HStack {
                            TextField("189", value: $bodyWeight, format: .number)
                                .textFieldStyle(.roundedBorder)
                            Text("lbs")
                        }
                    }
                }
                .padding(.top, 30)
                
                Button(action: {
                    if sex.isEmpty || heightFeet == nil || heightInches == nil || bodyWeight == nil {
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
        .ignoresSafeArea(.keyboard)
    }
}

struct SummaryPage: View {
    let name: String
    let onComplete: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        ScrollView {
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
                
                Button(action: {
                    withAnimation {
                        isAnimating = true
                        onComplete()
                    }
                }) {
                    Text("Start Your Journey")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: 180)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .scaleEffect(isAnimating ? 0.9 : 1.0)
                .padding(.top, 40)
            }
            .padding(40)
            .frame(maxWidth: 660, maxHeight: 650)
            .opacity(isAnimating ? 0 : 1)
        }
        .ignoresSafeArea(.keyboard)
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
