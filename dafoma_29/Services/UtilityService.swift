//
//  UtilityService.swift
//  dafoma_29
//
//  Created by Вячеслав on 8/25/25.
//

import Foundation
import SwiftUI

class UtilityService: ObservableObject {
    static let shared = UtilityService()
    
    @Published var playerStats = PlayerStats()
    @Published var recentSessions: [GameSession] = []
    
    private let userDefaults = UserDefaults.standard
    private let statsKey = "PlayerStats"
    private let sessionsKey = "RecentSessions"
    
    private init() {
        loadPlayerStats()
        loadRecentSessions()
    }
    
    // MARK: - Data Persistence
    
    func savePlayerStats() {
        if let encoded = try? JSONEncoder().encode(playerStats) {
            userDefaults.set(encoded, forKey: statsKey)
        }
    }
    
    func loadPlayerStats() {
        if let data = userDefaults.data(forKey: statsKey),
           let decoded = try? JSONDecoder().decode(PlayerStats.self, from: data) {
            playerStats = decoded
        }
    }
    
    func saveRecentSessions() {
        if let encoded = try? JSONEncoder().encode(recentSessions) {
            userDefaults.set(encoded, forKey: sessionsKey)
        }
    }
    
    func loadRecentSessions() {
        if let data = userDefaults.data(forKey: sessionsKey),
           let decoded = try? JSONDecoder().decode([GameSession].self, from: data) {
            recentSessions = decoded
        }
    }
    
    // MARK: - Session Management
    
    func recordSession(_ session: GameSession) {
        DispatchQueue.main.async {
            self.playerStats.updateWith(session: session)
            self.recentSessions.insert(session, at: 0)
            
            // Keep only the last 50 sessions
            if self.recentSessions.count > 50 {
                self.recentSessions = Array(self.recentSessions.prefix(50))
            }
            
            self.savePlayerStats()
            self.saveRecentSessions()
        }
    }
    
    // MARK: - Analytics & Insights
    
    func getPerformanceTrend() -> [PerformancePoint] {
        let sortedSessions = recentSessions.sorted { $0.startTime < $1.startTime }
        return sortedSessions.enumerated().map { index, session in
            PerformancePoint(
                sessionNumber: index + 1,
                score: session.score,
                accuracy: session.accuracy,
                date: session.startTime
            )
        }
    }
    
    func getGesturePerformance() -> [GesturePerformance] {
        return GestureType.allCases.compactMap { gestureType in
            guard let stats = playerStats.gestureStats[gestureType.rawValue] else { return nil }
            return GesturePerformance(
                gestureType: gestureType,
                accuracy: stats.averageAccuracy,
                averageTime: stats.averageTime,
                timesPerformed: stats.timesPerformed
            )
        }.sorted { $0.accuracy > $1.accuracy }
    }
    
    func getWeeklyProgress() -> [WeeklyProgress] {
        let calendar = Calendar.current
        let now = Date()
        var weeklyData: [WeeklyProgress] = []
        
        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: now) else { continue }
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
            
            let sessionsForDay = recentSessions.filter { session in
                session.startTime >= startOfDay && session.startTime < endOfDay
            }
            
            let totalScore = sessionsForDay.reduce(0) { $0 + $1.score }
            let totalTime = sessionsForDay.reduce(0.0) { $0 + $1.duration }
            
            weeklyData.append(WeeklyProgress(
                date: date,
                sessionsPlayed: sessionsForDay.count,
                totalScore: totalScore,
                totalPlayTime: totalTime
            ))
        }
        
        return weeklyData.reversed()
    }
    
    func getRecommendedLevel() -> Int {
        let recentPerformance = recentSessions.prefix(5)
        let averageAccuracy = recentPerformance.reduce(0.0) { $0 + $1.accuracy } / Double(max(recentPerformance.count, 1))
        
        if averageAccuracy > 0.9 {
            return min(playerStats.levelsCompleted + 2, 20)
        } else if averageAccuracy > 0.7 {
            return min(playerStats.levelsCompleted + 1, 20)
        } else {
            return max(playerStats.levelsCompleted, 1)
        }
    }
    
    func getAchievements() -> [Achievement] {
        var achievements: [Achievement] = []
        
        // Score-based achievements
        if playerStats.bestScore >= 1000 {
            achievements.append(Achievement(
                title: "Score Master",
                description: "Achieved a score of 1000+",
                icon: "star.fill",
                isUnlocked: true
            ))
        }
        
        if playerStats.bestScore >= 5000 {
            achievements.append(Achievement(
                title: "Gesture Legend",
                description: "Achieved a score of 5000+",
                icon: "crown.fill",
                isUnlocked: true
            ))
        }
        
        // Session-based achievements
        if playerStats.totalSessions >= 10 {
            achievements.append(Achievement(
                title: "Dedicated Player",
                description: "Completed 10 game sessions",
                icon: "gamecontroller.fill",
                isUnlocked: true
            ))
        }
        
        if playerStats.totalSessions >= 50 {
            achievements.append(Achievement(
                title: "Gesture Enthusiast",
                description: "Completed 50 game sessions",
                icon: "hand.raised.fill",
                isUnlocked: true
            ))
        }
        
        // Accuracy-based achievements
        if playerStats.averageAccuracy >= 0.9 {
            achievements.append(Achievement(
                title: "Precision Master",
                description: "Maintained 90%+ accuracy",
                icon: "target",
                isUnlocked: true
            ))
        }
        
        // Level-based achievements
        if playerStats.levelsCompleted >= 5 {
            achievements.append(Achievement(
                title: "Level Explorer",
                description: "Completed 5 levels",
                icon: "map.fill",
                isUnlocked: true
            ))
        }
        
        if playerStats.levelsCompleted >= 15 {
            achievements.append(Achievement(
                title: "Challenge Conqueror",
                description: "Completed 15 levels",
                icon: "mountain.2.fill",
                isUnlocked: true
            ))
        }
        
        return achievements
    }
    
    // MARK: - Data Reset
    
    func resetAllData() {
        DispatchQueue.main.async {
            self.playerStats = PlayerStats()
            self.recentSessions = []
            self.savePlayerStats()
            self.saveRecentSessions()
        }
    }
}

// MARK: - Supporting Data Structures

struct PerformancePoint: Identifiable {
    let id = UUID()
    let sessionNumber: Int
    let score: Int
    let accuracy: Double
    let date: Date
}

struct GesturePerformance: Identifiable {
    let id = UUID()
    let gestureType: GestureType
    let accuracy: Double
    let averageTime: Double
    let timesPerformed: Int
}

struct WeeklyProgress: Identifiable {
    let id = UUID()
    let date: Date
    let sessionsPlayed: Int
    let totalScore: Int
    let totalPlayTime: TimeInterval
}

struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let isUnlocked: Bool
}
