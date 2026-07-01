import SwiftUI

// MARK: - Onboarding Flow

/// Guides users through keyboard installation and setup.
/// Explains Full Access requirements transparently.
struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState
    @State private var currentStep = 0
    @State private var animateContent = false
    
    private let steps: [OnboardingStep] = [
        OnboardingStep(
            title: "Welcome to FlowLingo",
            subtitle: "Language disappears. You never leave your chat.",
            image: "sparkle.magnifyingglass",
            color: .indigo,
            detail: "Type naturally. We translate, localise, and adjust tone — all inside your keyboard."
        ),
        OnboardingStep(
            title: "Enable the Keyboard",
            subtitle: "Add FlowLingo in your keyboard settings",
            image: "keyboard",
            color: .blue,
            detail: """
            1. Go to Settings → General → Keyboard → Keyboards
            2. Add New Keyboard → FlowLingo
            3. Allow Full Access for translations
            
            🔒 Your privacy is protected. We never log keystrokes unless you tap Analyze.
            """
        ),
        OnboardingStep(
            title: "Copy to Analyze",
            subtitle: "Incoming foreign message? Just copy it.",
            image: "doc.on.clipboard",
            color: .emerald,
            detail: "Tap the clipboard banner to get instant translation, cultural context, slang breakdown, and suggested replies."
        ),
        OnboardingStep(
            title: "Choose Your Tone",
            subtitle: "Formal, Casual, Friendly, or Urgent",
            image: "heart.text.square",
            color: .purple,
            detail: "Toggle tones mid-conversation. AI adjusts word choice, formality, and cultural nuance automatically."
        ),
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator
            HStack {
                ForEach(0..<steps.count, id: \.self) { index in
                    Capsule()
                        .fill(index <= currentStep ? Color.indigo : Color(.systemGray4))
                        .frame(height: 3)
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
            
            // Content
            TabView(selection: $currentStep) {
                ForEach(0..<steps.count, id: \.self) { index in
                    OnboardingPageView(step: steps[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: currentStep)
            
            // Bottom actions
            VStack(spacing: 12) {
                if currentStep < steps.count - 1 {
                    Button(action: {
                        withAnimation { currentStep += 1 }
                        HapticFeedbackService.shared.toggle()
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.indigo)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    Button("Skip") {
                        withAnimation { currentStep = steps.count - 1 }
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                } else {
                    Button(action: {
                        appState.completeOnboarding()
                        HapticFeedbackService.shared.aiActionComplete()
                    }) {
                        Text("Start Using FlowLingo")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.indigo)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    Text("You can change these settings later")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(24)
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Onboarding Step Model

struct OnboardingStep {
    let title: String
    let subtitle: String
    let image: String
    let color: Color
    let detail: String
}

// MARK: - Onboarding Page

struct OnboardingPageView: View {
    let step: OnboardingStep
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(step.color.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: step.image)
                    .font(.system(size: 48))
                    .foregroundStyle(step.color)
            }
            .scaleEffect(animate ? 1 : 0.8)
            .opacity(animate ? 1 : 0)
            
            VStack(spacing: 8) {
                Text(step.title)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                
                Text(step.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(animate ? 1 : 0)
            .offset(y: animate ? 0 : 10)
            
            // Detail
            Text(step.detail)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : 10)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
                animate = true
            }
        }
        .onDisappear {
            animate = false
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
}