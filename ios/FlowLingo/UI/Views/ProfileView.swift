import SwiftUI

// MARK: - Profile View

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showSignIn = false
    
    var body: some View {
        NavigationStack {
            List {
                // Account Section
                Section {
                    if appState.isLoggedIn {
                        HStack(spacing: 16) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.indigo)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("User Name")
                                    .font(.headline)
                                Text("user@example.com")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    } else {
                        Button {
                            showSignIn = true
                        } label: {
                            HStack {
                                Spacer()
                                VStack(spacing: 8) {
                                    Image(systemName: "person.circle")
                                        .font(.system(size: 40))
                                    Text("Sign In")
                                        .font(.headline)
                                    Text("Sync your settings across devices")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 12)
                        }
                        .foregroundStyle(.primary)
                    }
                }
                
                // Saved Phrases
                Section {
                    if savedPhrases.isEmpty {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Image(systemName: "bookmark")
                                    .font(.title2)
                                    .foregroundStyle(.secondary)
                                Text("No saved phrases")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    } else {
                        ForEach(savedPhrases, id: \.self) { phrase in
                            Text(phrase)
                        }
                    }
                } header: {
                    Label("Saved Phrases", systemImage: "bookmark.fill")
                }
                
                // Usage Statistics
                Section {
                    HStack {
                        Label("Translations", systemImage: "textformat.alt")
                        Spacer()
                        Text("256")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Label("Analyses", systemImage: "sparkle.magnifyingglass")
                        Spacer()
                        Text("89")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Label("Languages Used", systemImage: "globe")
                        Spacer()
                        Text("4")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Label("Statistics", systemImage: "chart.bar.fill")
                }
                
                // Account Actions
                Section {
                    if appState.isLoggedIn {
                        Button("Sign Out", role: .destructive) {
                            appState.isLoggedIn = false
                        }
                    }
                    
                    Button("Delete Account", role: .destructive) {
                        // Show confirmation alert
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
    
    private let savedPhrases: [String] = []
}

#Preview {
    ProfileView()
        .environmentObject(AppState())
}