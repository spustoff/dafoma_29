//
//  ResultsView.swift
//  dafoma_29
//
//  Created by Вячеслав on 8/25/25.
//

import SwiftUI

struct ResultsView: View {
    let session: GameSession
    @ObservedObject var gameViewModel: GameViewModel
    @StateObject private var resultViewModel = ResultViewModel()
    @Environment(\.dismiss) private var dismiss
    
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
                    VStack(spacing: 25) {
                        // Header
                        headerView
                        
                        // Main stats
                        mainStatsView
                        
                        // Performance analysis
                        performanceAnalysisView
                        
                        // Challenge breakdown
                        challengeBreakdownView
                        
                        // Action buttons
                        actionButtonsView
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                        gameViewModel.returnToMenu()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        resultViewModel.shareScore(for: session)
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        .sheet(isPresented: $resultViewModel.showingShareSheet) {
            ShareSheet(text: resultViewModel.shareText)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 15) {
            // Completion status
            if session.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(red: 0.54, green: 0.71, blue: 0.02)) // #54b702
                
                Text("Level Completed!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            } else {
                Image(systemName: "clock.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(red: 1.0, green: 0.97, blue: 0.03)) // #fff707
                
                Text("Time's Up!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            Text("Level \(session.level)")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
    }
    
    private var mainStatsView: some View {
        VStack(spacing: 20) {
            // Score display
            VStack(spacing: 8) {
                Text("Final Score")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text("\(session.score)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.93, green: 0.0, blue: 0.29)) // #ee004a
            }
            
            // Key metrics
            HStack(spacing: 20) {
                MetricCard(
                    title: "Accuracy",
                    value: "\(Int(session.accuracy * 100))%",
                    icon: "target",
                    color: Color(red: 0.01, green: 0.47, blue: 0.99) // #0278fc
                )
                
                MetricCard(
                    title: "Time",
                    value: formatTime(session.duration),
                    icon: "clock",
                    color: Color(red: 1.0, green: 0.97, blue: 0.03) // #fff707
                )
                
                MetricCard(
                    title: "Challenges",
                    value: "\(session.challenges.filter { $0.isCompleted }.count)/\(session.challenges.count)",
                    icon: "list.bullet",
                    color: Color(red: 0.54, green: 0.71, blue: 0.02) // #54b702
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 25)
        .background(Color.white.opacity(0.9))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    private var performanceAnalysisView: some View {
        let analysis = resultViewModel.getPerformanceAnalysis(for: session)
        
        return VStack(alignment: .leading, spacing: 15) {
            Text("Performance Analysis")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                // Personal best indicator
                if analysis.isPersonalBest {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(Color(red: 1.0, green: 0.97, blue: 0.03)) // #fff707
                        
                        Text("New Personal Best!")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .background(Color(red: 1.0, green: 0.97, blue: 0.03).opacity(0.2)) // #fff707
                    .cornerRadius(10)
                }
                
                // Ratings
                HStack(spacing: 15) {
                    RatingCard(
                        title: "Accuracy",
                        rating: analysis.accuracyRating.rawValue,
                        icon: analysis.accuracyRating.icon,
                        color: analysis.accuracyRating.color
                    )
                    
                    RatingCard(
                        title: "Speed",
                        rating: analysis.speedRating.rawValue,
                        icon: analysis.speedRating.icon,
                        color: analysis.speedRating.color
                    )
                }
                
                // Recommendations
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recommendations:")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    ForEach(analysis.recommendations, id: \.self) { recommendation in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color(red: 1.0, green: 0.97, blue: 0.03)) // #fff707
                                .padding(.top, 2)
                            
                            Text(recommendation)
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Next level recommendation
                if analysis.nextRecommendedLevel > session.level {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(Color(red: 0.54, green: 0.71, blue: 0.02)) // #54b702
                        
                        Text("Try Level \(analysis.nextRecommendedLevel) next!")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .background(Color(red: 0.54, green: 0.71, blue: 0.02).opacity(0.2)) // #54b702
                    .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
    }
    
    private var challengeBreakdownView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Challenge Breakdown")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            LazyVStack(spacing: 8) {
                ForEach(resultViewModel.getChallengeBreakdown(for: session)) { result in
                    ChallengeResultRow(result: result)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 15) {
            // Play again button
            Button(action: {
                dismiss()
                gameViewModel.startGame(level: session.level)
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.clockwise")
                    Text("Play Again")
                }
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.01, green: 0.47, blue: 0.99), // #0278fc
                            Color(red: 0.83, green: 0.0, blue: 0.93)   // #d300ee
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            
            // Next level button (if applicable)
            if session.isCompleted && session.level < 20 {
                Button(action: {
                    dismiss()
                    gameViewModel.startGame(level: session.level + 1)
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.right")
                        Text("Next Level")
                    }
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 0.54, green: 0.71, blue: 0.02)) // #54b702
                    .cornerRadius(12)
                }
            }
            
            // Main menu button
            Button(action: {
                dismiss()
                gameViewModel.returnToMenu()
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "house")
                    Text("Main Menu")
                }
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.white.opacity(0.8))
                .cornerRadius(12)
            }
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct MetricCard: View {
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
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(Color.white.opacity(0.6))
        .cornerRadius(12)
    }
}

struct RatingCard: View {
    let title: String
    let rating: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text(rating)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.6))
        .cornerRadius(10)
    }
}

struct ChallengeResultRow: View {
    let result: ChallengeResult
    
    var body: some View {
        HStack(spacing: 12) {
            // Challenge number
            Text("\(result.challengeNumber)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(result.ratingColor)
                .clipShape(Circle())
            
            // Gesture info
            HStack(spacing: 8) {
                Image(systemName: result.gestureType.icon)
                    .font(.system(size: 16))
                    .foregroundColor(result.gestureType.color)
                
                Text(result.gestureType.displayName)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // Performance rating
            Text(result.performanceRating)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(result.ratingColor)
            
            // Completion status
            Image(systemName: result.isCompleted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(result.isCompleted ? Color(red: 0.54, green: 0.71, blue: 0.02) : Color(red: 0.93, green: 0.0, blue: 0.29))
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.5))
        .cornerRadius(8)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let text: String
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        return activityViewController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ResultsView(
        session: GameSession(level: 1),
        gameViewModel: GameViewModel()
    )
}
