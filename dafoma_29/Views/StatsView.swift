//
//  StatsView.swift
//  dafoma_29
//
//  Created by Вячеслав on 8/25/25.
//

import SwiftUI

struct StatsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var utilityService = UtilityService.shared
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
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
                    // Tab selector
                    tabSelectorView
                    
                    // Content
                    TabView(selection: $selectedTab) {
                        overviewTabView
                            .tag(0)
                        
                        gestureStatsTabView
                            .tag(1)
                        
                        achievementsTabView
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var tabSelectorView: some View {
        HStack(spacing: 0) {
            TabButton(title: "Overview", isSelected: selectedTab == 0) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = 0
                }
            }
            
            TabButton(title: "Gestures", isSelected: selectedTab == 1) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = 1
                }
            }
            
            TabButton(title: "Achievements", isSelected: selectedTab == 2) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedTab = 2
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.8))
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var overviewTabView: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Overall stats
                overallStatsView
                
                // Performance trend
                performanceTrendView
                
                // Weekly progress
                weeklyProgressView
                
                Spacer(minLength: 50)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
    
    private var gestureStatsTabView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Gesture performance
                gesturePerformanceView
                
                Spacer(minLength: 50)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
    
    private var achievementsTabView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Achievements
                achievementsView
                
                Spacer(minLength: 50)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
    
    private var overallStatsView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Overall Statistics")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                StatCard(
                    title: "Total Sessions",
                    value: "\(utilityService.playerStats.totalSessions)",
                    icon: "gamecontroller.fill",
                    color: Color(red: 0.01, green: 0.47, blue: 0.99) // #0278fc
                )
                
                StatCard(
                    title: "Best Score",
                    value: "\(utilityService.playerStats.bestScore)",
                    icon: "star.fill",
                    color: Color(red: 1.0, green: 0.97, blue: 0.03) // #fff707
                )
                
                StatCard(
                    title: "Total Score",
                    value: "\(utilityService.playerStats.totalScore)",
                    icon: "sum",
                    color: Color(red: 0.93, green: 0.0, blue: 0.29) // #ee004a
                )
                
                StatCard(
                    title: "Levels Completed",
                    value: "\(utilityService.playerStats.levelsCompleted)",
                    icon: "flag.fill",
                    color: Color(red: 0.54, green: 0.71, blue: 0.02) // #54b702
                )
                
                StatCard(
                    title: "Average Accuracy",
                    value: "\(Int(utilityService.playerStats.averageAccuracy * 100))%",
                    icon: "target",
                    color: Color(red: 0.83, green: 0.0, blue: 0.93) // #d300ee
                )
                
                StatCard(
                    title: "Play Time",
                    value: formatPlayTime(utilityService.playerStats.totalPlayTime),
                    icon: "clock.fill",
                    color: Color(red: 0.01, green: 0.47, blue: 0.99) // #0278fc
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
    }
    
    private var performanceTrendView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Performance Trend")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            let performanceData = utilityService.getPerformanceTrend()
            
            if performanceData.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("No performance data yet")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text("Play some games to see your progress!")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                // Simple performance visualization
                VStack(spacing: 10) {
                    HStack {
                        Text("Recent Sessions")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("Score Trend")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        ForEach(performanceData.suffix(10)) { point in
                            VStack(spacing: 4) {
                                Rectangle()
                                    .fill(Color(red: 0.01, green: 0.47, blue: 0.99)) // #0278fc
                                    .frame(width: 20, height: CGFloat(point.score) / 100.0 * 60 + 10)
                                
                                Text("\(point.sessionNumber)")
                                    .font(.system(size: 10, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .frame(height: 100)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
    }
    
    private var weeklyProgressView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Weekly Progress")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            let weeklyData = utilityService.getWeeklyProgress()
            
            VStack(spacing: 8) {
                ForEach(weeklyData) { day in
                    WeeklyProgressRow(progress: day)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
    }
    
    private var gesturePerformanceView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Gesture Performance")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            let gestureData = utilityService.getGesturePerformance()
            
            if gestureData.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "hand.wave")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("No gesture data yet")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text("Complete some challenges to see detailed gesture statistics!")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(gestureData) { performance in
                        GesturePerformanceRow(performance: performance)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
    }
    
    private var achievementsView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Achievements")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            let achievements = utilityService.getAchievements()
            
            if achievements.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "trophy")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("No achievements yet")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text("Keep playing to unlock achievements!")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(achievements) { achievement in
                        AchievementRow(achievement: achievement)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
    }
    
    private func formatPlayTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    isSelected ? 
                    Color(red: 0.01, green: 0.47, blue: 0.99) : // #0278fc
                    Color.clear
                )
                .cornerRadius(8)
        }
    }
}

struct WeeklyProgressRow: View {
    let progress: WeeklyProgress
    
    var body: some View {
        HStack(spacing: 15) {
            Text(dayName(from: progress.date))
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
                .frame(width: 40, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("\(progress.sessionsPlayed) sessions")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(progress.totalScore) pts")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0.93, green: 0.0, blue: 0.29)) // #ee004a
                }
                
                ProgressView(value: Double(progress.sessionsPlayed), total: 10.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.54, green: 0.71, blue: 0.02))) // #54b702
                    .scaleEffect(x: 1, y: 0.8, anchor: .center)
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.5))
        .cornerRadius(8)
    }
    
    private func dayName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

struct GesturePerformanceRow: View {
    let performance: GesturePerformance
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: performance.gestureType.icon)
                .font(.title2)
                .foregroundColor(performance.gestureType.color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(performance.gestureType.displayName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                HStack(spacing: 15) {
                    Text("\(Int(performance.accuracy * 100))% accuracy")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text("\(performance.timesPerformed) times")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.1fs", performance.averageTime))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("avg time")
                    .font(.system(size: 10, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.5))
        .cornerRadius(10)
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundColor(achievement.isUnlocked ? Color(red: 1.0, green: 0.97, blue: 0.03) : .gray) // #fff707
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                
                Text(achievement.description)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(Color(red: 0.54, green: 0.71, blue: 0.02)) // #54b702
            } else {
                Image(systemName: "lock.fill")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 12)
        .background(Color.white.opacity(achievement.isUnlocked ? 0.6 : 0.3))
        .cornerRadius(10)
    }
}

#Preview {
    StatsView()
}
