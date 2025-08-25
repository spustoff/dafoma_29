//
//  SettingsView.swift
//  dafoma_29
//
//  Created by Вячеслав on 8/25/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var utilityService = UtilityService.shared
    @State private var showingResetAlert = false
    @State private var showingAbout = false
    
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
                        
                        // Game Settings
                        gameSettingsView
                        
                        // Data Management
                        dataManagementView
                        
                        // About
                        aboutView
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Reset All Data", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                utilityService.resetAllData()
            }
        } message: {
            Text("This will permanently delete all your game progress, statistics, and achievements. This action cannot be undone.")
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 10) {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 50))
                .foregroundColor(Color(red: 0.01, green: 0.47, blue: 0.99)) // #0278fc
            
            Text("Settings")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text("Customize your experience")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
    }
    
    private var gameSettingsView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Game Settings")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                SettingsRow(
                    icon: "gamecontroller.fill",
                    title: "Haptic Feedback",
                    subtitle: "Feel vibrations during gameplay",
                    color: Color(red: 0.54, green: 0.71, blue: 0.02), // #54b702
                    action: {}
                )
                
                SettingsRow(
                    icon: "speaker.wave.2.fill",
                    title: "Sound Effects",
                    subtitle: "Play sounds for gestures and feedback",
                    color: Color(red: 1.0, green: 0.97, blue: 0.03), // #fff707
                    action: {}
                )
                
                SettingsRow(
                    icon: "speedometer",
                    title: "Difficulty Auto-Adjust",
                    subtitle: "Automatically adjust based on performance",
                    color: Color(red: 0.93, green: 0.0, blue: 0.29), // #ee004a
                    action: {}
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
    }
    
    private var dataManagementView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Data Management")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                SettingsRow(
                    icon: "icloud.and.arrow.up",
                    title: "Export Data",
                    subtitle: "Save your progress to share or backup",
                    color: Color(red: 0.01, green: 0.47, blue: 0.99), // #0278fc
                    action: { exportData() }
                )
                
                SettingsRow(
                    icon: "trash.fill",
                    title: "Reset All Data",
                    subtitle: "Permanently delete all progress",
                    color: Color(red: 0.93, green: 0.0, blue: 0.29), // #ee004a
                    action: { showingResetAlert = true }
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
    }
    
    private var aboutView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("About")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                SettingsRow(
                    icon: "info.circle.fill",
                    title: "About Gesture QuestSweet",
                    subtitle: "Learn more about the app",
                    color: Color(red: 0.83, green: 0.0, blue: 0.93), // #d300ee
                    action: { showingAbout = true }
                )
                
                SettingsRow(
                    icon: "star.fill",
                    title: "Rate the App",
                    subtitle: "Share your feedback on the App Store",
                    color: Color(red: 1.0, green: 0.97, blue: 0.03), // #fff707
                    action: { rateApp() }
                )
                
                SettingsRow(
                    icon: "envelope.fill",
                    title: "Contact Support",
                    subtitle: "Get help or report issues",
                    color: Color(red: 0.54, green: 0.71, blue: 0.02), // #54b702
                    action: { contactSupport() }
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.8))
        .cornerRadius(16)
    }
    
    // MARK: - Actions
    
    private func exportData() {
        // Implementation for exporting user data
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        if let statsData = try? encoder.encode(utilityService.playerStats),
           let sessionsData = try? encoder.encode(utilityService.recentSessions) {
            
            let exportData = [
                "stats": String(data: statsData, encoding: .utf8) ?? "",
                "sessions": String(data: sessionsData, encoding: .utf8) ?? "",
                "exportDate": ISO8601DateFormatter().string(from: Date())
            ]
            
            if let jsonData = try? JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                
                let activityVC = UIActivityViewController(
                    activityItems: [jsonString],
                    applicationActivities: nil
                )
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController?.present(activityVC, animated: true)
                }
            }
        }
    }
    
    private func rateApp() {
        // Implementation for rating the app
        if let url = URL(string: "https://apps.apple.com/app/id123456789") {
            UIApplication.shared.open(url)
        }
    }
    
    private func contactSupport() {
        // Implementation for contacting support
        if let url = URL(string: "mailto:support@gesturequest.com?subject=Gesture QuestSweet Support") {
            UIApplication.shared.open(url)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.5))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
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
                        // App icon and name
                        VStack(spacing: 15) {
                            Image(systemName: "hand.wave.fill")
                                .font(.system(size: 80))
                                .foregroundColor(Color(red: 0.93, green: 0.0, blue: 0.29)) // #ee004a
                            
                            Text("Gesture QuestSweet")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("Version 1.0")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 15) {
                            Text("About the App")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("Gesture QuestSweet is an engaging and playful game designed to enhance your hand-eye coordination and reflexes through dynamic gesture-based challenges. Master various gestures, track your progress, and improve your skills with progressively challenging levels.")
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(16)
                        
                        // Features
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Key Features")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                FeatureRow(icon: "hand.tap", text: "10 unique gesture types to master")
                                FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Comprehensive progress tracking")
                                FeatureRow(icon: "speedometer", text: "Dynamic difficulty adjustment")
                                FeatureRow(icon: "trophy", text: "Achievement system")
                                FeatureRow(icon: "square.and.arrow.up", text: "Score sharing capabilities")
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(16)
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("About")
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
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(red: 0.01, green: 0.47, blue: 0.99)) // #0278fc
                .frame(width: 20)
            
            Text(text)
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

#Preview {
    SettingsView()
}
