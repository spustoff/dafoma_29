//
//  GameViewModel.swift
//  dafoma_29
//
//  Created by Вячеслав on 8/25/25.
//

import Foundation
import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var currentSession: GameSession?
    @Published var gameState: GameState = .menu
    @Published var timeRemaining: Double = 0
    @Published var gestureCount: Int = 0
    @Published var showingResult = false
    @Published var showingOnboarding = false
    
    private var timer: Timer?
    private var challengeStartTime: Date?
    private let utilityService = UtilityService.shared
    
    enum GameState {
        case menu
        case onboarding
        case playing
        case paused
        case completed
        case result
    }
    
    init() {
        checkFirstLaunch()
    }
    
    // MARK: - Game Flow
    
    func startGame(level: Int = 1) {
        currentSession = GameSession(level: level)
        gameState = .playing
        startCurrentChallenge()
    }
    
    func pauseGame() {
        gameState = .paused
        stopTimer()
    }
    
    func resumeGame() {
        gameState = .playing
        startTimer()
    }
    
    func endGame() {
        stopTimer()
        gameState = .completed
        
        if let session = currentSession {
            utilityService.recordSession(session)
        }
        
        showingResult = true
    }
    
    func restartGame() {
        stopTimer()
        if let session = currentSession {
            startGame(level: session.level)
        } else {
            startGame()
        }
    }
    
    func returnToMenu() {
        stopTimer()
        currentSession = nil
        gameState = .menu
        showingResult = false
        resetChallengeState()
    }
    
    // MARK: - Challenge Management
    
    private func startCurrentChallenge() {
        guard let challenge = currentSession?.currentChallenge else {
            endGame()
            return
        }
        
        timeRemaining = challenge.timeLimit
        gestureCount = 0
        challengeStartTime = Date()
        startTimer()
    }
    
    private func completeCurrentChallenge() {
        guard var session = currentSession,
              let challenge = session.currentChallenge,
              let startTime = challengeStartTime else { return }
        
        let completionTime = Date().timeIntervalSince(startTime)
        let accuracy = Double(gestureCount) / Double(challenge.targetCount)
        
        session.completeCurrentChallenge(completionTime: completionTime, accuracy: min(accuracy, 1.0))
        currentSession = session
        
        stopTimer()
        
        // Check if game is complete
        if session.isCompleted {
            endGame()
        } else {
            // Move to next challenge after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.startCurrentChallenge()
            }
        }
    }
    
    // MARK: - Gesture Handling
    
    func handleGesture(_ gestureType: GestureType) {
        guard gameState == .playing,
              let challenge = currentSession?.currentChallenge else { return }
        
        let isCorrect = gestureType == challenge.gestureType
        currentSession?.recordGesture(isCorrect: isCorrect)
        
        if isCorrect {
            gestureCount += 1
            
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // Check if challenge is complete
            if gestureCount >= challenge.targetCount {
                completeCurrentChallenge()
            }
        } else {
            // Wrong gesture - add error feedback
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.error)
        }
    }
    
    // MARK: - Timer Management
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            DispatchQueue.main.async {
                self.timeRemaining -= 0.1
                
                if self.timeRemaining <= 0 {
                    self.timeUp()
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func timeUp() {
        guard let challenge = currentSession?.currentChallenge,
              let startTime = challengeStartTime else { return }
        
        let completionTime = Date().timeIntervalSince(startTime)
        let accuracy = Double(gestureCount) / Double(challenge.targetCount)
        
        currentSession?.completeCurrentChallenge(completionTime: completionTime, accuracy: min(accuracy, 1.0))
        
        stopTimer()
        
        // Check if game is complete
        if currentSession?.isCompleted == true {
            endGame()
        } else {
            // Move to next challenge
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.startCurrentChallenge()
            }
        }
    }
    
    // MARK: - Onboarding
    
    private func checkFirstLaunch() {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "HasLaunchedBefore")
        if !hasLaunchedBefore {
            showingOnboarding = true
            UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
        }
    }
    
    func completeOnboarding() {
        showingOnboarding = false
        gameState = .menu
    }
    
    // MARK: - Utility Methods
    
    private func resetChallengeState() {
        timeRemaining = 0
        gestureCount = 0
        challengeStartTime = nil
    }
    
    var progressPercentage: Double {
        guard let session = currentSession else { return 0.0 }
        return session.progress
    }
    
    var currentChallengeProgress: Double {
        guard let challenge = currentSession?.currentChallenge else { return 0.0 }
        return Double(gestureCount) / Double(challenge.targetCount)
    }
    
    deinit {
        stopTimer()
    }
}

