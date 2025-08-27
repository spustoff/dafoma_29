//
//  ResultViewModel.swift
//  dafoma_29
//
//  Created by Вячеслав on 8/25/25.
//

import Foundation
import SwiftUI
import Social

class ResultViewModel: ObservableObject {
    @Published var showingShareSheet = false
    @Published var shareText = ""
    
    private let utilityService = UtilityService.shared
    
    func generateShareText(for session: GameSession) -> String {
        let scoreText = "🎯 Score: \(session.score)"
        let accuracyText = "🎪 Accuracy: \(Int(session.accuracy * 100))%"
        let levelText = "🏆 Level: \(session.level)"
        let timeText = "⏱️ Time: \(formatTime(session.duration))"
        
        return """
        Just completed a Gesture QuestSweet challenge! 🎮
        
        \(scoreText)
        \(accuracyText)
        \(levelText)
        \(timeText)
        
        Can you beat my score? #GestureQuestSweet
        """
    }
    
    func shareScore(for session: GameSession) {
        shareText = generateShareText(for: session)
        showingShareSheet = true
    }
    
    func getPerformanceAnalysis(for session: GameSession) -> PerformanceAnalysis {
        let playerStats = utilityService.playerStats
        
        // Compare with personal best
        let isPersonalBest = session.score > playerStats.bestScore
        
        // Compare with average
        let averageScore = playerStats.totalSessions > 0 ? 
            Double(playerStats.totalScore) / Double(playerStats.totalSessions) : 0.0
        let scoreImprovement = session.score > Int(averageScore)
        
        // Accuracy analysis
        let accuracyRating: AccuracyRating
        if session.accuracy >= 0.9 {
            accuracyRating = .excellent
        } else if session.accuracy >= 0.7 {
            accuracyRating = .good
        } else if session.accuracy >= 0.5 {
            accuracyRating = .average
        } else {
            accuracyRating = .needsImprovement
        }
        
        // Speed analysis
        let averageTimePerChallenge = session.duration / Double(session.challenges.count)
        let speedRating: SpeedRating
        if averageTimePerChallenge <= 3.0 {
            speedRating = .fast
        } else if averageTimePerChallenge <= 5.0 {
            speedRating = .moderate
        } else {
            speedRating = .slow
        }
        
        // Generate recommendations
        let recommendations = generateRecommendations(
            accuracy: session.accuracy,
            speed: averageTimePerChallenge,
            level: session.level
        )
        
        return PerformanceAnalysis(
            isPersonalBest: isPersonalBest,
            scoreImprovement: scoreImprovement,
            accuracyRating: accuracyRating,
            speedRating: speedRating,
            recommendations: recommendations,
            nextRecommendedLevel: utilityService.getRecommendedLevel()
        )
    }
    
    private func generateRecommendations(accuracy: Double, speed: Double, level: Int) -> [String] {
        var recommendations: [String] = []
        
        if accuracy < 0.7 {
            recommendations.append("Focus on accuracy over speed")
            recommendations.append("Take time to identify the correct gesture")
        }
        
        if speed > 5.0 {
            recommendations.append("Try to respond faster to challenges")
            recommendations.append("Practice gesture recognition")
        }
        
        if accuracy > 0.9 && speed < 3.0 {
            recommendations.append("Excellent performance! Try a higher level")
            recommendations.append("Challenge yourself with more complex gestures")
        }
        
        if level < 5 {
            recommendations.append("Keep practicing to unlock new gesture types")
        }
        
        if recommendations.isEmpty {
            recommendations.append("Great job! Keep up the good work")
            recommendations.append("Try different gesture combinations")
        }
        
        return recommendations
    }
    
    func getChallengeBreakdown(for session: GameSession) -> [ChallengeResult] {
        return session.challenges.enumerated().map { index, challenge in
            ChallengeResult(
                challengeNumber: index + 1,
                gestureType: challenge.gestureType,
                isCompleted: challenge.isCompleted,
                completionTime: challenge.completionTime ?? 0,
                accuracy: challenge.accuracy ?? 0,
                timeLimit: challenge.timeLimit,
                targetCount: challenge.targetCount
            )
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Supporting Data Structures

struct PerformanceAnalysis {
    let isPersonalBest: Bool
    let scoreImprovement: Bool
    let accuracyRating: AccuracyRating
    let speedRating: SpeedRating
    let recommendations: [String]
    let nextRecommendedLevel: Int
}

enum AccuracyRating: String, CaseIterable {
    case excellent = "Excellent"
    case good = "Good"
    case average = "Average"
    case needsImprovement = "Needs Improvement"
    
    var color: Color {
        switch self {
        case .excellent:
            return Color(red: 0.54, green: 0.71, blue: 0.02) // #54b702
        case .good:
            return Color(red: 0.01, green: 0.47, blue: 0.99) // #0278fc
        case .average:
            return Color(red: 1.0, green: 0.97, blue: 0.03) // #fff707
        case .needsImprovement:
            return Color(red: 0.93, green: 0.0, blue: 0.29) // #ee004a
        }
    }
    
    var icon: String {
        switch self {
        case .excellent:
            return "star.fill"
        case .good:
            return "checkmark.circle.fill"
        case .average:
            return "minus.circle.fill"
        case .needsImprovement:
            return "exclamationmark.triangle.fill"
        }
    }
}

enum SpeedRating: String, CaseIterable {
    case fast = "Fast"
    case moderate = "Moderate"
    case slow = "Slow"
    
    var color: Color {
        switch self {
        case .fast:
            return Color(red: 0.54, green: 0.71, blue: 0.02) // #54b702
        case .moderate:
            return Color(red: 1.0, green: 0.97, blue: 0.03) // #fff707
        case .slow:
            return Color(red: 0.93, green: 0.0, blue: 0.29) // #ee004a
        }
    }
    
    var icon: String {
        switch self {
        case .fast:
            return "bolt.fill"
        case .moderate:
            return "gauge.medium"
        case .slow:
            return "tortoise.fill"
        }
    }
}

struct ChallengeResult: Identifiable {
    let id = UUID()
    let challengeNumber: Int
    let gestureType: GestureType
    let isCompleted: Bool
    let completionTime: Double
    let accuracy: Double
    let timeLimit: Double
    let targetCount: Int
    
    var performanceRating: String {
        if !isCompleted {
            return "Incomplete"
        }
        
        if accuracy >= 1.0 && completionTime <= timeLimit * 0.5 {
            return "Perfect"
        } else if accuracy >= 0.8 && completionTime <= timeLimit * 0.7 {
            return "Excellent"
        } else if accuracy >= 0.6 {
            return "Good"
        } else {
            return "Needs Practice"
        }
    }
    
    var ratingColor: Color {
        switch performanceRating {
        case "Perfect":
            return Color(red: 0.83, green: 0.0, blue: 0.93) // #d300ee
        case "Excellent":
            return Color(red: 0.54, green: 0.71, blue: 0.02) // #54b702
        case "Good":
            return Color(red: 0.01, green: 0.47, blue: 0.99) // #0278fc
        case "Needs Practice":
            return Color(red: 0.93, green: 0.0, blue: 0.29) // #ee004a
        default:
            return Color.gray
        }
    }
}

