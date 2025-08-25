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
                gamePlayingView
            } else if gameViewModel.gameState == .paused {
                pauseMenuView
            }
        }
        .sheet(isPresented: $gameViewModel.showingResult) {
            ResultsView(
                session: gameViewModel.currentSession ?? GameSession(),
                gameViewModel: gameViewModel
            )
        }
    }
    
    private var gamePlayingView: some View {
        VStack(spacing: 0) {
            // Top UI
            topUIView
            
            Spacer()
            
            // Main game area
            mainGameAreaView
            
            Spacer()
            
            // Bottom UI
            bottomUIView
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 40)
    }
    
    private var topUIView: some View {
        HStack {
            // Pause button
            Button(action: {
                gameViewModel.pauseGame()
                showingPauseMenu = true
            }) {
                Image(systemName: "pause.fill")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.8))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // Score
            VStack(spacing: 4) {
                Text("Score")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text("\(gameViewModel.currentSession?.score ?? 0)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.8))
            .cornerRadius(12)
            
            Spacer()
            
            // Timer
            VStack(spacing: 4) {
                Text("Time")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text(String(format: "%.1f", gameViewModel.timeRemaining))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(gameViewModel.timeRemaining <= 3.0 ? Color(red: 0.93, green: 0.0, blue: 0.29) : .primary)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.8))
            .cornerRadius(12)
        }
    }
    
    private var mainGameAreaView: some View {
        VStack(spacing: 30) {
            // Challenge info
            if let challenge = gameViewModel.currentSession?.currentChallenge {
                challengeInfoView(challenge: challenge)
            }
            
            // Gesture area
            gestureAreaView
            
            // Progress indicator
            progressIndicatorView
        }
    }
    
    private func challengeInfoView(challenge: GestureChallenge) -> some View {
        VStack(spacing: 15) {
            Text("Perform this gesture:")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
            
            VStack(spacing: 10) {
                Image(systemName: challenge.gestureType.icon)
                    .font(.system(size: 60))
                    .foregroundColor(challenge.gestureType.color)
                
                Text(challenge.gestureType.displayName)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            Text("\(gameViewModel.gestureCount)/\(challenge.targetCount) completed")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 25)
        .background(Color.white.opacity(0.9))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private var gestureAreaView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.3))
                .frame(width: 280, height: 280)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.5), lineWidth: 2)
                )
            
            // Interactive element for gestures
            RoundedRectangle(cornerRadius: 16)
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
                .frame(width: 120, height: 120)
                .scaleEffect(scaleAmount)
                .rotationEffect(.degrees(rotationAngle))
                .offset(dragOffset)
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
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
    
    private var progressIndicatorView: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Challenge Progress")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(gameViewModel.currentSession?.currentChallengeIndex ?? 0 + 1)/\(gameViewModel.currentSession?.challenges.count ?? 0)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: gameViewModel.progressPercentage)
                .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.54, green: 0.71, blue: 0.02))) // #54b702
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            // Current challenge progress
            if let challenge = gameViewModel.currentSession?.currentChallenge {
                HStack {
                    Text("Current: \(gameViewModel.gestureCount)/\(challenge.targetCount)")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                ProgressView(value: gameViewModel.currentChallengeProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.93, green: 0.0, blue: 0.29))) // #ee004a
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(Color.white.opacity(0.8))
        .cornerRadius(12)
    }
    
    private var bottomUIView: some View {
        HStack {
            // Level indicator
            VStack(spacing: 4) {
                Text("Level")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text("\(gameViewModel.currentSession?.level ?? 1)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.8))
            .cornerRadius(12)
            
            Spacer()
            
            // Accuracy
            VStack(spacing: 4) {
                Text("Accuracy")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text("\(Int((gameViewModel.currentSession?.accuracy ?? 0) * 100))%")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.8))
            .cornerRadius(12)
        }
    }
    
    private var pauseMenuView: some View {
        VStack(spacing: 30) {
            Text("Game Paused")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            VStack(spacing: 15) {
                Button(action: {
                    showingPauseMenu = false
                    gameViewModel.resumeGame()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "play.fill")
                        Text("Resume")
                    }
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 0.54, green: 0.71, blue: 0.02)) // #54b702
                    .cornerRadius(12)
                }
                
                Button(action: {
                    gameViewModel.restartGame()
                    showingPauseMenu = false
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.clockwise")
                        Text("Restart")
                    }
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 0.01, green: 0.47, blue: 0.99)) // #0278fc
                    .cornerRadius(12)
                }
                
                Button(action: {
                    gameViewModel.returnToMenu()
                    showingPauseMenu = false
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "house.fill")
                        Text("Main Menu")
                    }
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 0.93, green: 0.0, blue: 0.29)) // #ee004a
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.3))
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.95))
                .padding(.horizontal, 40)
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
