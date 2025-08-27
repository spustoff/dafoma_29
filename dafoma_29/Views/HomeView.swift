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
                
                GeometryReader { geometry in
                    let isIPad = geometry.size.width > 600
                    let horizontalPadding: CGFloat = isIPad ? max(40, (geometry.size.width - 800) / 2) : 20
                    
                    ScrollView {
                        VStack(spacing: isIPad ? 40 : 30) {
                            // Header
                            headerView(isIPad: isIPad)
                            
                            if isIPad {
                                // iPad layout - side by side
                                HStack(alignment: .top, spacing: 40) {
                                    VStack(spacing: 30) {
                                        quickStatsView(isIPad: isIPad)
                                        levelSelectionView(isIPad: isIPad)
                                        playButtonView(isIPad: isIPad)
                                    }
                                    .frame(maxWidth: 400)
                                    
                                    VStack(spacing: 30) {
                                        recentPerformanceView(isIPad: isIPad)
                                    }
                                    .frame(maxWidth: 400)
                                }
                                .frame(maxWidth: .infinity)
                            } else {
                                // iPhone layout - vertical
                                VStack(spacing: 30) {
                                    quickStatsView(isIPad: isIPad)
                                    levelSelectionView(isIPad: isIPad)
                                    playButtonView(isIPad: isIPad)
                                    recentPerformanceView(isIPad: isIPad)
                                }
                            }
                            
                            Spacer(minLength: isIPad ? 60 : 100)
                        }
                        .padding(.horizontal, horizontalPadding)
                        .padding(.top, isIPad ? 40 : 20)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
    
    private func headerView(isIPad: Bool) -> some View {
        VStack(spacing: isIPad ? 15 : 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Gesture")
                        .font(.system(size: isIPad ? 48 : 36, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("QuestSweet")
                        .font(.system(size: isIPad ? 48 : 36, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.93, green: 0.0, blue: 0.29)) // #ee004a
                }
                
                Spacer()
                
                HStack(spacing: isIPad ? 20 : 15) {
                    Button(action: { showingStats = true }) {
                        Image(systemName: "chart.bar.fill")
                            .font(isIPad ? .title : .title2)
                            .foregroundColor(.primary)
                            .frame(width: isIPad ? 56 : 44, height: isIPad ? 56 : 44)
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                    }
                    
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(isIPad ? .title : .title2)
                            .foregroundColor(.primary)
                            .frame(width: isIPad ? 56 : 44, height: isIPad ? 56 : 44)
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                    }
                }
            }
            
            Text("Master gestures, track progress")
                .font(.system(size: isIPad ? 20 : 16, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
    }
    
    private func quickStatsView(isIPad: Bool) -> some View {
        let spacing: CGFloat = isIPad ? 30 : 20
        
        return Group {
            if isIPad {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: spacing) {
                    StatCard(
                        title: "Best Score",
                        value: "\(utilityService.playerStats.bestScore)",
                        icon: "star.fill",
                        color: Color(red: 1.0, green: 0.97, blue: 0.03), // #fff707
                        isIPad: isIPad
                    )
                    
                    StatCard(
                        title: "Level",
                        value: "\(utilityService.playerStats.levelsCompleted)",
                        icon: "flag.fill",
                        color: Color(red: 0.54, green: 0.71, blue: 0.02), // #54b702
                        isIPad: isIPad
                    )
                    
                    StatCard(
                        title: "Accuracy",
                        value: "\(Int(utilityService.playerStats.averageAccuracy * 100))%",
                        icon: "target",
                        color: Color(red: 0.01, green: 0.47, blue: 0.99), // #0278fc
                        isIPad: isIPad
                    )
                }
            } else {
                HStack(spacing: spacing) {
                    StatCard(
                        title: "Best Score",
                        value: "\(utilityService.playerStats.bestScore)",
                        icon: "star.fill",
                        color: Color(red: 1.0, green: 0.97, blue: 0.03), // #fff707
                        isIPad: isIPad
                    )
                    
                    StatCard(
                        title: "Level",
                        value: "\(utilityService.playerStats.levelsCompleted)",
                        icon: "flag.fill",
                        color: Color(red: 0.54, green: 0.71, blue: 0.02), // #54b702
                        isIPad: isIPad
                    )
                    
                    StatCard(
                        title: "Accuracy",
                        value: "\(Int(utilityService.playerStats.averageAccuracy * 100))%",
                        icon: "target",
                        color: Color(red: 0.01, green: 0.47, blue: 0.99), // #0278fc
                        isIPad: isIPad
                    )
                }
            }
        }
    }
    
    private func levelSelectionView(isIPad: Bool) -> some View {
        VStack(alignment: .leading, spacing: isIPad ? 20 : 15) {
            HStack {
                Text("Select Level")
                    .font(.system(size: isIPad ? 24 : 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("Recommended: \(utilityService.getRecommendedLevel())")
                    .font(.system(size: isIPad ? 16 : 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            if isIPad {
                // iPad: Use a grid layout for better space utilization
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 5), spacing: 15) {
                    ForEach(1...20, id: \.self) { level in
                        LevelButton(
                            level: level,
                            isSelected: selectedLevel == level,
                            isUnlocked: level <= max(utilityService.playerStats.levelsCompleted + 1, 1),
                            isRecommended: level == utilityService.getRecommendedLevel(),
                            isIPad: isIPad
                        ) {
                            selectedLevel = level
                        }
                    }
                }
            } else {
                // iPhone: Keep horizontal scroll
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(1...20, id: \.self) { level in
                            LevelButton(
                                level: level,
                                isSelected: selectedLevel == level,
                                isUnlocked: level <= max(utilityService.playerStats.levelsCompleted + 1, 1),
                                isRecommended: level == utilityService.getRecommendedLevel(),
                                isIPad: isIPad
                            ) {
                                selectedLevel = level
                            }
                        }
                    }
                    .padding(.horizontal, 5)
                }
            }
        }
        .padding(.horizontal, isIPad ? 30 : 20)
        .padding(.vertical, isIPad ? 25 : 20)
        .background(Color.white.opacity(0.8))
        .cornerRadius(isIPad ? 20 : 16)
    }
    
    private func playButtonView(isIPad: Bool) -> some View {
        Button(action: {
            gameViewModel.startGame(level: selectedLevel)
        }) {
            HStack(spacing: isIPad ? 20 : 15) {
                Image(systemName: "play.fill")
                    .font(isIPad ? .title : .title2)
                
                Text("Start Game")
                    .font(.system(size: isIPad ? 24 : 20, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: isIPad ? 80 : 60)
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
            .cornerRadius(isIPad ? 20 : 16)
            .shadow(color: Color.black.opacity(0.2), radius: isIPad ? 12 : 8, x: 0, y: isIPad ? 6 : 4)
        }
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: selectedLevel)
    }
    
    private func recentPerformanceView(isIPad: Bool) -> some View {
        VStack(alignment: .leading, spacing: isIPad ? 20 : 15) {
            Text("Recent Performance")
                .font(.system(size: isIPad ? 24 : 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            if utilityService.recentSessions.isEmpty {
                VStack(spacing: isIPad ? 15 : 10) {
                    Image(systemName: "hand.wave")
                        .font(.system(size: isIPad ? 60 : 40))
                        .foregroundColor(.secondary)
                    
                    Text("No games played yet")
                        .font(.system(size: isIPad ? 20 : 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text("Start your first game to see your progress!")
                        .font(.system(size: isIPad ? 16 : 14, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, isIPad ? 60 : 40)
            } else {
                LazyVStack(spacing: isIPad ? 15 : 10) {
                    ForEach(utilityService.recentSessions.prefix(isIPad ? 5 : 3)) { session in
                        RecentSessionRow(session: session, isIPad: isIPad)
                    }
                }
            }
        }
        .padding(.horizontal, isIPad ? 30 : 20)
        .padding(.vertical, isIPad ? 25 : 20)
        .background(Color.white.opacity(0.8))
        .cornerRadius(isIPad ? 20 : 16)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let isIPad: Bool
    
    var body: some View {
        VStack(spacing: isIPad ? 12 : 8) {
            Image(systemName: icon)
                .font(isIPad ? .title : .title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: isIPad ? 22 : 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: isIPad ? 14 : 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, isIPad ? 20 : 15)
        .background(Color.white.opacity(0.8))
        .cornerRadius(isIPad ? 16 : 12)
    }
}

struct LevelButton: View {
    let level: Int
    let isSelected: Bool
    let isUnlocked: Bool
    let isRecommended: Bool
    let isIPad: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: isIPad ? 16 : 12)
                    .fill(backgroundColor)
                    .frame(width: isIPad ? 80 : 60, height: isIPad ? 80 : 60)
                
                if isRecommended && isUnlocked {
                    RoundedRectangle(cornerRadius: isIPad ? 16 : 12)
                        .stroke(Color(red: 1.0, green: 0.97, blue: 0.03), lineWidth: isIPad ? 3 : 2) // #fff707
                        .frame(width: isIPad ? 80 : 60, height: isIPad ? 80 : 60)
                }
                
                VStack(spacing: isIPad ? 4 : 2) {
                    if isUnlocked {
                        Text("\(level)")
                            .font(.system(size: isIPad ? 20 : 16, weight: .bold, design: .rounded))
                            .foregroundColor(textColor)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: isIPad ? 18 : 14))
                            .foregroundColor(.gray)
                    }
                    
                    if isRecommended && isUnlocked {
                        Circle()
                            .fill(Color(red: 1.0, green: 0.97, blue: 0.03)) // #fff707
                            .frame(width: isIPad ? 6 : 4, height: isIPad ? 6 : 4)
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
    let isIPad: Bool
    
    var body: some View {
        HStack(spacing: isIPad ? 20 : 15) {
            VStack(alignment: .leading, spacing: isIPad ? 6 : 4) {
                Text("Level \(session.level)")
                    .font(.system(size: isIPad ? 18 : 16, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(formatDate(session.startTime))
                    .font(.system(size: isIPad ? 14 : 12, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: isIPad ? 6 : 4) {
                Text("\(session.score)")
                    .font(.system(size: isIPad ? 18 : 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.93, green: 0.0, blue: 0.29)) // #ee004a
                
                Text("\(Int(session.accuracy * 100))% acc")
                    .font(.system(size: isIPad ? 14 : 12, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: isIPad ? 16 : 12))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, isIPad ? 20 : 15)
        .padding(.vertical, isIPad ? 16 : 12)
        .background(Color.white.opacity(0.5))
        .cornerRadius(isIPad ? 14 : 10)
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

