//
//  GameSession.swift
//  dafoma_29
//
//  Created by Вячеслав on 8/25/25.
//

import Foundation

struct GameSession: Identifiable, Codable {
    let id = UUID()
    let startTime: Date
    var endTime: Date?
    var challenges: [GestureChallenge]
    var currentChallengeIndex: Int = 0
    var score: Int = 0
    var level: Int = 1
    var totalGestures: Int = 0
    var correctGestures: Int = 0
    var isCompleted: Bool = false
    
    init(level: Int = 1) {
        self.startTime = Date()
        self.level = level
        self.challenges = GameSession.generateChallenges(for: level)
    }
    
    var duration: TimeInterval {
        if let endTime = endTime {
            return endTime.timeIntervalSince(startTime)
        }
        return Date().timeIntervalSince(startTime)
    }
    
    var accuracy: Double {
        guard totalGestures > 0 else { return 0.0 }
        return Double(correctGestures) / Double(totalGestures)
    }
    
    var currentChallenge: GestureChallenge? {
        guard currentChallengeIndex < challenges.count else { return nil }
        return challenges[currentChallengeIndex]
    }
    
    var progress: Double {
        guard !challenges.isEmpty else { return 0.0 }
        return Double(currentChallengeIndex) / Double(challenges.count)
    }
    
    mutating func completeCurrentChallenge(completionTime: Double, accuracy: Double) {
        guard currentChallengeIndex < challenges.count else { return }
        
        challenges[currentChallengeIndex].isCompleted = true
        challenges[currentChallengeIndex].completionTime = completionTime
        challenges[currentChallengeIndex].accuracy = accuracy
        
        // Calculate score based on performance
        let baseScore = challenges[currentChallengeIndex].gestureType.difficulty * 100
        let timeBonus = max(0, Int((challenges[currentChallengeIndex].timeLimit - completionTime) * 10))
        let accuracyBonus = Int(accuracy * 100)
        
        score += baseScore + timeBonus + accuracyBonus
        currentChallengeIndex += 1
        
        if currentChallengeIndex >= challenges.count {
            isCompleted = true
            endTime = Date()
        }
    }
    
    mutating func recordGesture(isCorrect: Bool) {
        totalGestures += 1
        if isCorrect {
            correctGestures += 1
        }
    }
    
    static func generateChallenges(for level: Int) -> [GestureChallenge] {
        var challenges: [GestureChallenge] = []
        let challengeCount = min(5 + level, 15) // 5-15 challenges based on level
        
        for i in 0..<challengeCount {
            let availableGestures = GestureType.allCases.filter { $0.difficulty <= min(level, 4) }
            let gestureType = availableGestures.randomElement() ?? .tap
            
            let targetCount = max(1, level + i / 2) // Increasing targets
            let timeLimit = max(3.0, 10.0 - Double(level) * 0.5) // Decreasing time
            
            let challenge = GestureChallenge(
                gestureType: gestureType,
                targetCount: targetCount,
                timeLimit: timeLimit,
                level: level
            )
            
            challenges.append(challenge)
        }
        
        return challenges
    }
}

struct PlayerStats: Codable {
    var totalSessions: Int = 0
    var totalScore: Int = 0
    var bestScore: Int = 0
    var totalPlayTime: TimeInterval = 0
    var averageAccuracy: Double = 0.0
    var levelsCompleted: Int = 0
    var gestureStats: [String: GestureStats] = [:]
    var lastPlayedDate: Date?
    
    mutating func updateWith(session: GameSession) {
        totalSessions += 1
        totalScore += session.score
        bestScore = max(bestScore, session.score)
        totalPlayTime += session.duration
        lastPlayedDate = Date()
        
        if session.isCompleted {
            levelsCompleted = max(levelsCompleted, session.level)
        }
        
        // Update gesture-specific stats
        for challenge in session.challenges where challenge.isCompleted {
            let gestureKey = challenge.gestureType.rawValue
            if gestureStats[gestureKey] == nil {
                gestureStats[gestureKey] = GestureStats()
            }
            gestureStats[gestureKey]?.updateWith(challenge: challenge)
        }
        
        // Recalculate average accuracy
        let totalAccuracy = gestureStats.values.reduce(0.0) { $0 + $1.averageAccuracy }
        averageAccuracy = gestureStats.isEmpty ? 0.0 : totalAccuracy / Double(gestureStats.count)
    }
}

struct GestureStats: Codable {
    var timesPerformed: Int = 0
    var totalAccuracy: Double = 0.0
    var averageAccuracy: Double = 0.0
    var bestTime: Double = Double.infinity
    var averageTime: Double = 0.0
    var totalTime: Double = 0.0
    
    mutating func updateWith(challenge: GestureChallenge) {
        guard let completionTime = challenge.completionTime,
              let accuracy = challenge.accuracy else { return }
        
        timesPerformed += 1
        totalAccuracy += accuracy
        averageAccuracy = totalAccuracy / Double(timesPerformed)
        
        bestTime = min(bestTime, completionTime)
        totalTime += completionTime
        averageTime = totalTime / Double(timesPerformed)
    }
}

