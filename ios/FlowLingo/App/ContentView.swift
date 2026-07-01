import SwiftUI

// MARK: - Content View

/// Root view — shows onboarding flow or main dashboard depending on completion state.
struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        Group {
            if !appState.isOnboardingComplete {
                OnboardingView()
            } else {
                MainTabView()
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 0.96)))
        .animation(.easeInOut(duration: 0.3), value: appState.isOnboardingComplete)
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "square.grid.2x2")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
        .tint(Color(red: 0.310, green: 0.275, blue: 0.898)) // Indigo 600
    }
}

// MARK: - Dashboard View

struct DashboardView: View {
    @EnvironmentObject private var appState: AppState
    @State private var todayActions = 42
    @State private var streakDays = 7
    @State private var recentTranslations: [RecentTranslation] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Stats Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                    ], spacing: 16) {
                        StatCard(
                            title: "Today's Actions",
                            value: "\(todayActions)",
                            icon: "sparkle.magnifyingglass",
                            color: .indigo
                        )
                        StatCard(
                            title: "Day Streak",
                            value: "\(streakDays)",
                            icon: "flame.fill",
                            color: .orange
                        )
                    }
                    .padding(.horizontal)
                    
                    // Quick Actions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Actions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                QuickActionButton(
                                    title: "Translate",
                                    icon: "textformat.alt",
                                    color: .indigo
                                )
                                QuickActionButton(
                                    title: "Saved",
                                    icon: "bookmark.fill",
                                    color: .emerald
                                )
                                QuickActionButton(
                                    title: "History",
                                    icon: "clock.fill",
                                    color: .blue
                                )
                                QuickActionButton(
                                    title: "Memory",
                                    icon: "brain.head.profile",
                                    color: .purple
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Recent Translations
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if recentTranslations.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "text.bubble")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.secondary)
                                Text("No translations yet")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("Start typing in any app with the FlowLingo keyboard")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("FlowLingo")
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Text(value)
                .font(.title.bold())
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.primary)
        }
        .frame(width: 72)
    }
}

struct RecentTranslation: Identifiable {
    let id = UUID()
    let sourceText: String
    let translatedText: String
    let sourceLanguage: String
    let targetLanguage: String
    let timestamp: Date
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}