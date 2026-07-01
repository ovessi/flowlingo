import SwiftUI

// MARK: - FlowLingo App

/// The companion app for the FlowLingo keyboard extension.
/// Provides onboarding, settings, subscription management, and usage analytics.
@main
struct FlowLingoApp: App {
    
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    configureAppearance()
                }
        }
    }
    
    private func configureAppearance() {
        // Global appearance customization
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold),
            .foregroundColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? .white : UIColor(white: 0.067, alpha: 1.0)
            }
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}

// MARK: - App State

final class AppState: ObservableObject {
    @Published var isOnboardingComplete = UserDefaults.standard.bool(forKey: "onboarding_complete")
    @Published var isLoggedIn = false
    @Published var subscriptionTier: SubscriptionTier = .free
    @Published var preferences = UserPreferences.default
    
    init() {
        // Load saved preferences
        loadPreferences()
    }
    
    func completeOnboarding() {
        isOnboardingComplete = true
        UserDefaults.standard.set(true, forKey: "onboarding_complete")
    }
    
    func savePreferences() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(preferences) {
            UserDefaults.standard.set(data, forKey: "user_preferences")
        }
    }
    
    private func loadPreferences() {
        guard let data = UserDefaults.standard.data(forKey: "user_preferences") else { return }
        let decoder = JSONDecoder()
        if let prefs = try? decoder.decode(UserPreferences.self, from: data) {
            preferences = prefs
        }
    }
}