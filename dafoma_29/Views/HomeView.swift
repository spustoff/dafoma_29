//
//  HomeView.swift
//  dafoma_29
//
//  Created by Вячеслав on 8/25/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var gameViewModel = GameViewModel()
    @StateObject private var utilityService = UtilityService.shared
    @State private var showingSettings = false
    @State private var showingStats = false
    @State private var selectedLevel = 1
    
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
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        headerView
                        
                        // Quick Stats
                        quickStatsView
                        
                        // Level Selection
                        levelSelectionView
                        
                        // Play Button
                        playButtonView
                        
                        // Recent Performance
                        recentPerformanceView
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $gameViewModel.showingOnboarding) {
            OnboardingView(gameViewModel: gameViewModel)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingStats) {
            StatsView()
        }
        .fullScreenCover(isPresented: .constant(gameViewModel.gameState == .playing)) {
            GameView(gameViewModel: gameViewModel)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Gesture")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("QuestSweet")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.93, green: 0.0, blue: 0.29)) // #ee004a
                }
                
                Spacer()
                
                HStack(spacing: 15) {
                    Button(action: { showingStats = true }) {
                        Image(systemName: "chart.bar.fill")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                    }
                }
            }
            
            Text("Master gestures, track progress")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
    }
    
    private var quickStatsView: some View {
        HStack(spacing: 20) {
            StatCard(
                title: "Best Score",
                value: "\(utilityService.playerStats.bestScore)",
                icon: "star.fill",
                color: Color(red: 1.0, green: 0.97, blue: 0.03) // #fff707
            )
            
            StatCard(
                title: "Level",
                value: "\(utilityService.playerStats.levelsCompleted)",
                icon: "flag.fill",
                color: Color(red: 0.54, green: 0.71, blue: 0.02) // #54b702
            )
            
            StatCard(
                title: "Accuracy",
                value: "\(Int(utilityService.playerStats.averageAccuracy * 100))%",
                icon: "target",
                color: Color(red: 0.01, green: 0.47, blue: 0.99) // #0278fc
            )
        }
    }
    
    private var levelSelectionView: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Select Level")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("Recommended: \(utilityService.getRecommendedLevel())")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(1...20, id: \.self) { level in
                        LevelButton(
                            level: level,
                            isSelected: selectedLevel == level,
                            isUnlocked: level <= max(utilityService.playerStats.levelsCompleted + 1, 1),
                            isRecommended: level == utilityService.getRecommendedLevel()
                        ) {
                            selectedLevel = level
                        }
                    }
                }
                .padding(.horizontal, 5)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
    }
    
    private var playButtonView: some View {
        Button(action: {
            gameViewModel.startGame(level: selectedLevel)
        }) {
            HStack(spacing: 15) {
                Image(systemName: "play.fill")
                    .font(.title2)
                
                Text("Start Game")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
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
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: selectedLevel)
    }
    
    private var recentPerformanceView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Performance")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            if utilityService.recentSessions.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "hand.wave")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("No games played yet")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text("Start your first game to see your progress!")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(utilityService.recentSessions.prefix(3)) { session in
                        RecentSessionRow(session: session)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(Color.white.opacity(0.8))
        .cornerRadius(12)
    }
}

struct LevelButton: View {
    let level: Int
    let isSelected: Bool
    let isUnlocked: Bool
    let isRecommended: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .frame(width: 60, height: 60)
                
                if isRecommended && isUnlocked {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 1.0, green: 0.97, blue: 0.03), lineWidth: 2) // #fff707
                        .frame(width: 60, height: 60)
                }
                
                VStack(spacing: 2) {
                    if isUnlocked {
                        Text("\(level)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(textColor)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    if isRecommended && isUnlocked {
                        Circle()
                            .fill(Color(red: 1.0, green: 0.97, blue: 0.03)) // #fff707
                            .frame(width: 4, height: 4)
                    }
                }
            }
        }
        .disabled(!isUnlocked)
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private var backgroundColor: Color {
        if !isUnlocked {
            return Color.gray.opacity(0.3)
        } else if isSelected {
            return Color(red: 0.93, green: 0.0, blue: 0.29) // #ee004a
        } else {
            return Color.white.opacity(0.8)
        }
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else {
            return .primary
        }
    }
}

struct RecentSessionRow: View {
    let session: GameSession
    
    var body: some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Level \(session.level)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(formatDate(session.startTime))
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(session.score)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.93, green: 0.0, blue: 0.29)) // #ee004a
                
                Text("\(Int(session.accuracy * 100))% acc")
                    .font(.system(size: 12, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.5))
        .cornerRadius(10)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    HomeView()
}
