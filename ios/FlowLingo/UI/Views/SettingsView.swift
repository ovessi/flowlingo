import SwiftUI

// MARK: - Settings View

/// Full settings dashboard for the FlowLingo companion app.
/// Controls language preferences, theme, haptics, subscription, and privacy.
struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        NavigationStack {
            Form {
                // Language Section
                Section {
                    NavigationLink {
                        LanguagePickerView(
                            selectedCode: $appState.preferences.nativeLanguage,
                            title: "Native Language"
                        )
                    } label: {
                        HStack {
                            Label("My Language", systemImage: "person")
                            Spacer()
                            Text(codeToFlag(appState.preferences.nativeLanguage))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    NavigationLink {
                        LanguagePickerView(
                            selectedCode: $appState.preferences.targetLanguage,
                            title: "Target Language"
                        )
                    } label: {
                        HStack {
                            Label("Translate To", systemImage: "arrow.right")
                            Spacer()
                            Text(codeToFlag(appState.preferences.targetLanguage))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Picker("Default Tone", selection: $appState.preferences.defaultTone) {
                        ForEach(Tone.allCases, id: \.self) { tone in
                            Label(tone.displayName, systemImage: tone.systemSymbol)
                                .tag(tone)
                        }
                    }
                } header: {
                    Text("Language & Tone")
                }
                
                // Keyboard Section
                Section {
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString + "FlowLingo") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("Keyboard Settings", systemImage: "keyboard")
                    }
                    
                    Toggle(isOn: $appState.preferences.clipboardDetectionEnabled) {
                        VStack(alignment: .leading, spacing: 2) {
                            Label("Smart Clipboard", systemImage: "doc.on.clipboard")
                            Text("Detect copied text for quick analysis")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onChange(of: appState.preferences.clipboardDetectionEnabled) { _, newValue in
                        ClipboardDetectionService.shared.setOptedIn(newValue)
                        appState.savePreferences()
                    }
                    
                    Toggle(isOn: $appState.preferences.hapticsEnabled) {
                        VStack(alignment: .leading, spacing: 2) {
                            Label("Haptic Feedback", systemImage: "iphone.radiowaves.left.and.right")
                            Text("Subtle vibrations on actions")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onChange(of: appState.preferences.hapticsEnabled) { _, newValue in
                        UserDefaults.standard.set(newValue, forKey: "haptics_enabled")
                        appState.savePreferences()
                    }
                } header: {
                    Text("Keyboard")
                }
                
                // Appearance Section
                Section {
                    Picker("Theme", selection: $appState.preferences.theme) {
                        Text("System").tag(ThemeMode.system)
                        Text("Light").tag(ThemeMode.light)
                        Text("Dark").tag(ThemeMode.dark)
                    }
                } header: {
                    Text("Appearance")
                }
                
                // Subscription Section
                Section {
                    HStack {
                        Label("Current Plan", systemImage: "crown")
                        Spacer()
                        Text(appState.subscriptionTier.displayName)
                            .foregroundStyle(.secondary)
                    }
                    
                    if appState.subscriptionTier == .free {
                        NavigationLink("Upgrade to Premium") {
                            SubscriptionView()
                        }
                    }
                } header: {
                    Text("Subscription")
                }
                
                // Privacy Section
                Section {
                    NavigationLink("Privacy & Security") {
                        PrivacyInfoView()
                    }
                    
                    NavigationLink("AI Memory") {
                        AIMemoryView()
                    }
                    
                    Button("Reset Clipboard Permission") {
                        UserDefaults.standard.set(false, forKey: "clipboard_has_prompted")
                        UserDefaults.standard.set(false, forKey: "clipboard_opt_in")
                    }
                    .foregroundColor(.red)
                } header: {
                    Text("Privacy")
                }
                
                // Data Section
                Section {
                    HStack {
                        Label("Actions Today", systemImage: "number")
                        Spacer()
                        Text("42")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Label("Translations Saved", systemImage: "bookmark")
                        Spacer()
                        Text("128")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Usage")
                }
            }
            .navigationTitle("Settings")
        }
        .onDisappear {
            appState.savePreferences()
        }
    }
    
    private func codeToFlag(_ code: String) -> String {
        let flags: [String: String] = [
            "en": "🇬🇧", "es": "🇪🇸", "fr": "🇫🇷", "de": "🇩🇪",
            "ja": "🇯🇵", "ko": "🇰🇷", "zh-CN": "🇨🇳", "zh-TW": "🇹🇼",
            "ar": "🇸🇦", "he": "🇮🇱", "hi": "🇮🇳", "pt": "🇵🇹",
            "ru": "🇷🇺", "it": "🇮🇹", "nl": "🇳🇱", "tr": "🇹🇷",
            "vi": "🇻🇳", "th": "🇹🇭", "id": "🇮🇩"
        ]
        return flags[code] ?? code.uppercased()
    }
}

// MARK: - Language Picker

struct LanguagePickerView: View {
    @Binding var selectedCode: String
    let title: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List(Language.supportedLanguages, id: \.code) { language in
            Button {
                selectedCode = language.code
                dismiss()
            } label: {
                HStack {
                    Text(language.nativeName)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(language.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if selectedCode == language.code {
                        Image(systemName: "checkmark")
                            .foregroundColor(.indigo)
                            .font(.weight(.semibold))
                    }
                }
            }
        }
        .navigationTitle(title)
    }
}

// MARK: - Privacy Info View

struct PrivacyInfoView: View {
    var body: some View {
        List {
            Section {
                Label("No Passive Logging", systemImage: "hand.raised.fill")
                Label("Clipboard Optional", systemImage: "doc.on.clipboard")
                Label("PII Redaction", systemImage: "eye.slash")
                Label("Always Encrypted", systemImage: "lock.fill")
                Label("Opt-in Memory", systemImage: "brain")
            } header: {
                Text("Your Privacy at a Glance")
            } footer: {
                Text("FlowLingo never transmits keystrokes unless you explicitly tap Analyze. Full Access is required for network translation but we never use it for surveillance.")
            }
        }
        .navigationTitle("Privacy & Security")
    }
}

// MARK: - AI Memory View

struct AIMemoryView: View {
    @State private var memories: [String] = []
    
    var body: some View {
        List {
            if memories.isEmpty {
                ContentUnavailableView(
                    "No Memories",
                    systemImage: "brain.head.profile",
                    description: Text("Save phrases and preferences for personalized translations. AI Memory is disabled by default.")
                )
            } else {
                ForEach(memories, id: \.self) { memory in
                    Text(memory)
                }
                .onDelete(perform: deleteMemory)
                
                Button("Clear All Memories", role: .destructive) {
                    memories.removeAll()
                }
            }
        }
        .navigationTitle("AI Memory")
    }
    
    private func deleteMemory(at offsets: IndexSet) {
        memories.remove(atOffsets: offsets)
    }
}

// MARK: - Subscription View

struct SubscriptionView: View {
    var body: some View {
        List {
            // Premium features
            VStack(spacing: 16) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.indigo)
                
                Text("Unlock FlowLingo Premium")
                    .font(.title2.bold())
                
                Text("Unlimited translations, tone profiles, offline packs, and AI memory.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
            
            Section {
                FeatureRow(icon: "infinity", title: "Unlimited AI Actions", subtitle: "No daily limits")
                FeatureRow(icon: "person.text.rectangle", title: "Tone Profiles", subtitle: "Save custom tones")
                FeatureRow(icon: "square.and.arrow.down", title: "Offline Packs", subtitle: "Translate without internet")
                FeatureRow(icon: "brain.head.profile", title: "AI Memory", subtitle: "Personalized translations")
            } header: {
                Text("Premium Features")
            }
            
            Section {
                Button(action: {}) {
                    HStack {
                        Text("Premium Monthly")
                        Spacer()
                        Text("$4.99/mo")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Button(action: {}) {
                    HStack {
                        Text("Premium Annual")
                            .foregroundStyle(.indigo)
                        Spacer()
                        Text("$39.99/yr")
                            .foregroundStyle(.indigo)
                            .fontWeight(.semibold)
                    }
                }
            } header: {
                Text("Choose a Plan")
            } footer: {
                Text("Subscription auto-renews. Cancel anytime.")
            }
        }
        .navigationTitle("Upgrade")
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.indigo)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}