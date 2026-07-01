import UIKit

// MARK: - Haptic Feedback Service

/// Provides consistent haptic feedback throughout the keyboard extension.
/// Designed with subtlety — the keyboard should feel premium, not buzzy.
final class HapticFeedbackService {
    
    static let shared = HapticFeedbackService()
    
    private var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: "haptics_enabled")
    }
    
    private init() {
        // Register default
        if UserDefaults.standard.object(forKey: "haptics_enabled") == nil {
            UserDefaults.standard.set(true, forKey: "haptics_enabled")
        }
    }
    
    // MARK: - Key Press Feedback
    
    /// Light tap on regular keypress — subtle, feels like typing on a premium keyboard
    func keyPress() {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred(intensity: 0.5)
    }
    
    /// Slightly firmer feedback for modifier keys (shift, backspace)
    func modifierKeyPress() {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred(intensity: 0.4)
    }
    
    // MARK: - Action Feedback
    
    /// Medium impact when AI action completes successfully
    func aiActionComplete() {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred(intensity: 0.7)
        
        // Follow with a notification for emphasis
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let notification = UINotificationFeedbackGenerator()
            notification.prepare()
            notification.notificationOccurred(.success)
        }
    }
    
    /// Double-tap pattern for errors
    func error() {
        guard isEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
        
        // Secondary error pulse
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            let impact = UIImpactFeedbackGenerator(style: .rigid)
            impact.prepare()
            impact.impactOccurred(intensity: 0.8)
        }
    }
    
    /// Light tap when toggling a mode or switching language
    func toggle() {
        guard isEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    /// Subtle tap when suggestion chip is tapped
    func suggestionTap() {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred(intensity: 0.6)
    }
    
    /// Feedback for long-press on suggestion chip (preview)
    func longPressPreview() {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred(intensity: 0.4)
    }
    
    // MARK: - Transient Feedback
    
    /// Light impact when FlowBar toggles visibility
    func flowBarToggle() {
        guard isEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred(intensity: 0.3)
    }
}