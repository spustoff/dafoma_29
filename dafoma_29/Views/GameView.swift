//
//  GameView.swift
//  dafoma_29
//
//  Created by Вячеслав on 8/25/25.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var gameViewModel: GameViewModel
    @State private var dragOffset = CGSize.zero
    @State private var rotationAngle: Double = 0
    @State private var scaleAmount: CGFloat = 1.0
    @State private var showingPauseMenu = false
    
    var body: some View {
        GeometryReader { geometry in
            let isIPad = geometry.size.width > 600
            
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
                
                if gameViewModel.gameState == .playing {
                    gamePlayingView(isIPad: isIPad, geometry: geometry)
                } else if gameViewModel.gameState == .paused {
                    pauseMenuView(isIPad: isIPad)
                }
            }
        }
        .sheet(isPresented: $gameViewModel.showingResult) {
            ResultsView(
                session: gameViewModel.currentSession ?? GameSession(),
                gameViewModel: gameViewModel
            )
        }
    }
    
    private func gamePlayingView(isIPad: Bool, geometry: GeometryProxy) -> some View {
        let horizontalPadding: CGFloat = isIPad ? max(40, (geometry.size.width - 1000) / 2) : 20
        
        return Group {
            if isIPad {
                // iPad layout - side by side
                HStack(spacing: 60) {
                    // Left side - Game info and controls
                    VStack(spacing: 40) {
                        topUIView(isIPad: isIPad)
                        
                        if let challenge = gameViewModel.currentSession?.currentChallenge {
                            challengeInfoView(challenge: challenge, isIPad: isIPad)
                        }
                        
                        progressIndicatorView(isIPad: isIPad)
                        bottomUIView(isIPad: isIPad)
                        
                        Spacer()
                    }
                    .frame(maxWidth: 400)
                    
                    // Right side - Gesture area
                    VStack {
                        Spacer()
                        gestureAreaView(isIPad: isIPad)
                        Spacer()
                    }
                    .frame(maxWidth: 500)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, 60)
            } else {
                // iPhone layout - vertical
                VStack(spacing: 0) {
                    // Top UI
                    topUIView(isIPad: isIPad)
                    
                    Spacer()
                    
                    // Main game area
                    mainGameAreaView(isIPad: isIPad)
                    
                    Spacer()
                    
                    // Bottom UI
                    bottomUIView(isIPad: isIPad)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, 40)
            }
        }
    }
    
    private func topUIView(isIPad: Bool) -> some View {
        HStack {
            // Pause button
            Button(action: {
                gameViewModel.pauseGame()
                showingPauseMenu = true
            }) {
                Image(systemName: "pause.fill")
                    .font(isIPad ? .title : .title2)
                    .foregroundColor(.primary)
                    .frame(width: isIPad ? 56 : 44, height: isIPad ? 56 : 44)
                    .background(Color.white.opacity(0.8))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // Score
            VStack(spacing: isIPad ? 6 : 4) {
                Text("Score")
                    .font(.system(size: isIPad ? 14 : 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text("\(gameViewModel.currentSession?.score ?? 0)")
                    .font(.system(size: isIPad ? 24 : 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, isIPad ? 20 : 15)
            .padding(.vertical, isIPad ? 12 : 8)
            .background(Color.white.opacity(0.8))
            .cornerRadius(isIPad ? 16 : 12)
            
            Spacer()
            
            // Timer
            VStack(spacing: isIPad ? 6 : 4) {
                Text("Time")
                    .font(.system(size: isIPad ? 14 : 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text(String(format: "%.1f", gameViewModel.timeRemaining))
                    .font(.system(size: isIPad ? 24 : 20, weight: .bold, design: .rounded))
                    .foregroundColor(gameViewModel.timeRemaining <= 3.0 ? Color(red: 0.93, green: 0.0, blue: 0.29) : .primary)
            }
            .padding(.horizontal, isIPad ? 20 : 15)
            .padding(.vertical, isIPad ? 12 : 8)
            .background(Color.white.opacity(0.8))
            .cornerRadius(isIPad ? 16 : 12)
        }
    }
    
    private func mainGameAreaView(isIPad: Bool) -> some View {
        VStack(spacing: isIPad ? 40 : 30) {
            // Challenge info
            if let challenge = gameViewModel.currentSession?.currentChallenge {
                challengeInfoView(challenge: challenge, isIPad: isIPad)
            }
            
            // Gesture area
            gestureAreaView(isIPad: isIPad)
            
            // Progress indicator
            progressIndicatorView(isIPad: isIPad)
        }
    }
    
    private func challengeInfoView(challenge: GestureChallenge, isIPad: Bool) -> some View {
        VStack(spacing: isIPad ? 20 : 15) {
            Text("Perform this gesture:")
                .font(.system(size: isIPad ? 22 : 18, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
            
            VStack(spacing: isIPad ? 15 : 10) {
                Image(systemName: challenge.gestureType.icon)
                    .font(.system(size: isIPad ? 80 : 60))
                    .foregroundColor(challenge.gestureType.color)
                
                Text(challenge.gestureType.displayName)
                    .font(.system(size: isIPad ? 32 : 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            Text("\(gameViewModel.gestureCount)/\(challenge.targetCount) completed")
                .font(.system(size: isIPad ? 20 : 16, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, isIPad ? 30 : 20)
        .padding(.vertical, isIPad ? 35 : 25)
        .background(Color.white.opacity(0.9))
        .cornerRadius(isIPad ? 28 : 20)
        .shadow(color: Color.black.opacity(0.1), radius: isIPad ? 15 : 10, x: 0, y: isIPad ? 8 : 5)
    }
    
    private func gestureAreaView(isIPad: Bool) -> some View {
        let areaSize: CGFloat = isIPad ? 400 : 280
        let elementSize: CGFloat = isIPad ? 160 : 120
        
        return ZStack {
            RoundedRectangle(cornerRadius: isIPad ? 28 : 20)
                .fill(Color.white.opacity(0.3))
                .frame(width: areaSize, height: areaSize)
                .overlay(
                    RoundedRectangle(cornerRadius: isIPad ? 28 : 20)
                        .stroke(Color.white.opacity(0.5), lineWidth: isIPad ? 3 : 2)
                )
            
            // Interactive element for gestures
            RoundedRectangle(cornerRadius: isIPad ? 20 : 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.01, green: 0.47, blue: 0.99), // #0278fc
                            Color(red: 0.83, green: 0.0, blue: 0.93)   // #d300ee
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: elementSize, height: elementSize)
                .scaleEffect(scaleAmount)
                .rotationEffect(.degrees(rotationAngle))
                .offset(dragOffset)
                .shadow(color: Color.black.opacity(0.2), radius: isIPad ? 12 : 8, x: 0, y: isIPad ? 6 : 4)
        }
        .gesture(gestureRecognizer)
    }
    
    private var gestureRecognizer: some Gesture {
        SimultaneousGesture(
            // Tap gesture
            TapGesture()
                .onEnded { _ in
                    gameViewModel.handleGesture(.tap)
                    animateSuccess()
                },
            
            SimultaneousGesture(
                // Double tap gesture
                TapGesture(count: 2)
                    .onEnded { _ in
                        gameViewModel.handleGesture(.doubleTap)
                        animateSuccess()
                    },
                
                SimultaneousGesture(
                    // Long press gesture
                    LongPressGesture(minimumDuration: 0.8)
                        .onEnded { _ in
                            gameViewModel.handleGesture(.longPress)
                            animateSuccess()
                        },
                    
                    SimultaneousGesture(
                        // Drag gesture
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation
                            }
                            .onEnded { value in
                                let distance = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
                                
                                if distance > 50 {
                                    // Determine swipe direction
                                    let angle = atan2(value.translation.height, value.translation.width)
                                    let degrees = angle * 180 / .pi
                                    
                                    if degrees >= -45 && degrees <= 45 {
                                        gameViewModel.handleGesture(.swipeRight)
                                    } else if degrees >= 45 && degrees <= 135 {
                                        gameViewModel.handleGesture(.swipeDown)
                                    } else if degrees >= -135 && degrees <= -45 {
                                        gameViewModel.handleGesture(.swipeUp)
                                    } else {
                                        gameViewModel.handleGesture(.swipeLeft)
                                    }
                                } else {
                                    gameViewModel.handleGesture(.drag)
                                }
                                
                                animateSuccess()
                                
                                // Reset position
                                withAnimation(.spring()) {
                                    dragOffset = .zero
                                }
                            },
                        
                        SimultaneousGesture(
                            // Rotation gesture
                            RotationGesture()
                                .onChanged { angle in
                                    rotationAngle = angle.degrees
                                }
                                .onEnded { _ in
                                    gameViewModel.handleGesture(.rotate)
                                    animateSuccess()
                                    
                                    // Reset rotation
                                    withAnimation(.spring()) {
                                        rotationAngle = 0
                                    }
                                },
                            
                            // Magnification gesture (pinch)
                            MagnificationGesture()
                                .onChanged { scale in
                                    scaleAmount = scale
                                }
                                .onEnded { _ in
                                    gameViewModel.handleGesture(.pinch)
                                    animateSuccess()
                                    
                                    // Reset scale
                                    withAnimation(.spring()) {
                                        scaleAmount = 1.0
                                    }
                                }
                        )
                    )
                )
            )
        )
    }
    
    private func progressIndicatorView(isIPad: Bool) -> some View {
        VStack(spacing: isIPad ? 15 : 10) {
            HStack {
                Text("Challenge Progress")
                    .font(.system(size: isIPad ? 16 : 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(gameViewModel.currentSession?.currentChallengeIndex ?? 0 + 1)/\(gameViewModel.currentSession?.challenges.count ?? 0)")
                    .font(.system(size: isIPad ? 16 : 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: gameViewModel.progressPercentage)
                .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.54, green: 0.71, blue: 0.02))) // #54b702
                .scaleEffect(x: 1, y: isIPad ? 3 : 2, anchor: .center)
            
            // Current challenge progress
            if let challenge = gameViewModel.currentSession?.currentChallenge {
                HStack {
                    Text("Current: \(gameViewModel.gestureCount)/\(challenge.targetCount)")
                        .font(.system(size: isIPad ? 14 : 12, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                ProgressView(value: gameViewModel.currentChallengeProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.93, green: 0.0, blue: 0.29))) // #ee004a
                    .scaleEffect(x: 1, y: isIPad ? 2 : 1.5, anchor: .center)
            }
        }
        .padding(.horizontal, isIPad ? 30 : 20)
        .padding(.vertical, isIPad ? 20 : 15)
        .background(Color.white.opacity(0.8))
        .cornerRadius(isIPad ? 16 : 12)
    }
    
    private func bottomUIView(isIPad: Bool) -> some View {
        HStack {
            // Level indicator
            VStack(spacing: isIPad ? 6 : 4) {
                Text("Level")
                    .font(.system(size: isIPad ? 14 : 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text("\(gameViewModel.currentSession?.level ?? 1)")
                    .font(.system(size: isIPad ? 22 : 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, isIPad ? 20 : 15)
            .padding(.vertical, isIPad ? 12 : 8)
            .background(Color.white.opacity(0.8))
            .cornerRadius(isIPad ? 16 : 12)
            
            Spacer()
            
            // Accuracy
            VStack(spacing: isIPad ? 6 : 4) {
                Text("Accuracy")
                    .font(.system(size: isIPad ? 14 : 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text("\(Int((gameViewModel.currentSession?.accuracy ?? 0) * 100))%")
                    .font(.system(size: isIPad ? 22 : 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, isIPad ? 20 : 15)
            .padding(.vertical, isIPad ? 12 : 8)
            .background(Color.white.opacity(0.8))
            .cornerRadius(isIPad ? 16 : 12)
        }
    }
    
    private func pauseMenuView(isIPad: Bool) -> some View {
        VStack(spacing: isIPad ? 40 : 30) {
            Text("Game Paused")
                .font(.system(size: isIPad ? 36 : 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            VStack(spacing: isIPad ? 20 : 15) {
                Button(action: {
                    showingPauseMenu = false
                    gameViewModel.resumeGame()
                }) {
                    HStack(spacing: isIPad ? 15 : 10) {
                        Image(systemName: "play.fill")
                        Text("Resume")
                    }
                    .font(.system(size: isIPad ? 22 : 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: isIPad ? 70 : 50)
                    .background(Color(red: 0.54, green: 0.71, blue: 0.02)) // #54b702
                    .cornerRadius(isIPad ? 16 : 12)
                }
                
                Button(action: {
                    gameViewModel.restartGame()
                    showingPauseMenu = false
                }) {
                    HStack(spacing: isIPad ? 15 : 10) {
                        Image(systemName: "arrow.clockwise")
                        Text("Restart")
                    }
                    .font(.system(size: isIPad ? 22 : 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: isIPad ? 70 : 50)
                    .background(Color(red: 0.01, green: 0.47, blue: 0.99)) // #0278fc
                    .cornerRadius(isIPad ? 16 : 12)
                }
                
                Button(action: {
                    gameViewModel.returnToMenu()
                    showingPauseMenu = false
                }) {
                    HStack(spacing: isIPad ? 15 : 10) {
                        Image(systemName: "house.fill")
                        Text("Main Menu")
                    }
                    .font(.system(size: isIPad ? 22 : 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: isIPad ? 70 : 50)
                    .background(Color(red: 0.93, green: 0.0, blue: 0.29)) // #ee004a
                    .cornerRadius(isIPad ? 16 : 12)
                }
            }
            .padding(.horizontal, isIPad ? 60 : 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.3))
        .background(
            RoundedRectangle(cornerRadius: isIPad ? 28 : 20)
                .fill(Color.white.opacity(0.95))
                .padding(.horizontal, isIPad ? 80 : 40)
        )
    }
    
    private func animateSuccess() {
        withAnimation(.easeInOut(duration: 0.2)) {
            scaleAmount = 1.2
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.2)) {
                scaleAmount = 1.0
            }
        }
    }
}

#Preview {
    GameView(gameViewModel: GameViewModel())
}
