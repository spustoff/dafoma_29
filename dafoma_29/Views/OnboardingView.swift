//
//  OnboardingView.swift
//  dafoma_29
//
//  Created by Вячеслав on 8/25/25.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var gameViewModel: GameViewModel
    @State private var currentPage = 0
    @State private var animationOffset: CGFloat = 0
    
    private let pages = OnboardingPage.allPages
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.8, blue: 0.78), // #f1ccc6
                    Color(red: 0.33, green: 0.75, blue: 0.96)  // #53bef4
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    
                    Button("Skip") {
                        gameViewModel.completeOnboarding()
                    }
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(
                            page: pages[index],
                            isLastPage: index == pages.count - 1,
                            gameViewModel: gameViewModel
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.5), value: currentPage)
                
                Spacer()
                
                // Page indicator and navigation
                VStack(spacing: 20) {
                    // Page dots
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? Color(red: 0.93, green: 0.0, blue: 0.29) : Color.white.opacity(0.5)) // #ee004a
                                .frame(width: 10, height: 10)
                                .scaleEffect(currentPage == index ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.3), value: currentPage)
                        }
                    }
                    
                    // Navigation buttons
                    HStack(spacing: 20) {
                        if currentPage > 0 {
                            Button(action: {
                                withAnimation {
                                    currentPage -= 1
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "chevron.left")
                                    Text("Back")
                                }
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(25)
                            }
                        }
                        
                        Spacer()
                        
                        if currentPage < pages.count - 1 {
                            Button(action: {
                                withAnimation {
                                    currentPage += 1
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Text("Next")
                                    Image(systemName: "chevron.right")
                                }
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.93, green: 0.0, blue: 0.29), // #ee004a
                                            Color(red: 0.83, green: 0.0, blue: 0.93)  // #d300ee
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(25)
                            }
                        } else {
                            Button(action: {
                                gameViewModel.completeOnboarding()
                            }) {
                                HStack(spacing: 8) {
                                    Text("Get Started")
                                    Image(systemName: "arrow.right")
                                }
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 25)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.54, green: 0.71, blue: 0.02), // #54b702
                                            Color(red: 0.01, green: 0.47, blue: 0.99)  // #0278fc
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(25)
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            animationOffset = 10
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isLastPage: Bool
    @ObservedObject var gameViewModel: GameViewModel
    @State private var gestureScale: CGFloat = 1.0
    @State private var gestureRotation: Double = 0
    
    var body: some View {
        VStack(spacing: 40) {
            // Icon with animation
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 200, height: 200)
                
                Image(systemName: page.icon)
                    .font(.system(size: 80))
                    .foregroundColor(page.color)
                    .scaleEffect(gestureScale)
                    .rotationEffect(.degrees(gestureRotation))
            }
            .onAppear {
                startGestureAnimation()
            }
            
            // Content
            VStack(spacing: 20) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.system(size: 18, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
                
                if !page.features.isEmpty {
                    VStack(spacing: 12) {
                        ForEach(page.features, id: \.self) { feature in
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color(red: 0.54, green: 0.71, blue: 0.02)) // #54b702
                                
                                Text(feature)
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 40)
                        }
                    }
                    .padding(.top, 10)
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func startGestureAnimation() {
        switch page.animationType {
        case .pulse:
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                gestureScale = 1.2
            }
        case .rotate:
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                gestureRotation = 360
            }
        case .bounce:
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                gestureScale = 1.1
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let features: [String]
    let animationType: AnimationType
    
    enum AnimationType {
        case pulse, rotate, bounce
    }
    
    static let allPages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to\nGesture QuestSweet",
            description: "Master the art of gestures through engaging challenges that enhance your coordination and reflexes.",
            icon: "hand.wave.fill",
            color: Color(red: 0.93, green: 0.0, blue: 0.29), // #ee004a
            features: [],
            animationType: .pulse
        ),
        
        OnboardingPage(
            title: "Learn Gestures",
            description: "Discover 10 unique gesture types, from simple taps to complex rotations and pinches.",
            icon: "hand.tap.fill",
            color: Color(red: 0.01, green: 0.47, blue: 0.99), // #0278fc
            features: [
                "Tap and Double Tap",
                "Swipe in all directions",
                "Long Press and Drag",
                "Pinch and Rotate"
            ],
            animationType: .bounce
        ),
        
        OnboardingPage(
            title: "Track Progress",
            description: "Monitor your performance with detailed statistics and unlock achievements as you improve.",
            icon: "chart.line.uptrend.xyaxis",
            color: Color(red: 0.54, green: 0.71, blue: 0.02), // #54b702
            features: [
                "Detailed performance analytics",
                "Achievement system",
                "Progress tracking",
                "Score sharing"
            ],
            animationType: .pulse
        ),
        
        OnboardingPage(
            title: "Dynamic Difficulty",
            description: "Experience adaptive challenges that adjust to your skill level for the perfect balance of fun and challenge.",
            icon: "speedometer",
            color: Color(red: 1.0, green: 0.97, blue: 0.03), // #fff707
            features: [
                "20 challenging levels",
                "Adaptive difficulty",
                "Progressive challenges",
                "Personalized recommendations"
            ],
            animationType: .rotate
        ),
        
        OnboardingPage(
            title: "Ready to Play?",
            description: "You're all set! Start your gesture journey and see how far your skills can take you.",
            icon: "gamecontroller.fill",
            color: Color(red: 0.83, green: 0.0, blue: 0.93), // #d300ee
            features: [],
            animationType: .bounce
        )
    ]
}

#Preview {
    OnboardingView(gameViewModel: GameViewModel())
}
