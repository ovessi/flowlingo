import UIKit

// MARK: - Clipboard Detection Service

/// Manages clipboard access with full privacy compliance.
/// - First use shows explicit opt-in alert
/// - Only checks clipboard when user copies text and keyboard is active
/// - Never logs clipboard content passively
/// - Respects iOS 14+ clipboard notifications
final class ClipboardDetectionService {
    
    static let shared = ClipboardDetectionService()
    
    // MARK: - Privacy State
    
    /// Whether the user has opted into clipboard detection
    private var isOptedIn: Bool {
        get { UserDefaults.standard.bool(forKey: "clipboard_opt_in") }
        set { UserDefaults.standard.set(newValue, forKey: "clipboard_opt_in") }
    }
    
    /// Whether the user has been shown the opt-in prompt
    private var hasPrompted: Bool {
        get { UserDefaults.standard.bool(forKey: "clipboard_has_prompted") }
        set { UserDefaults.standard.set(newValue, forKey: "clipboard_has_prompted") }
    }
    
    /// Last clipboard change count (iOS 14+ API)
    private var lastChangeCount: Int = UIPasteboard.general.changeCount
    
    /// Timestamp of last clipboard check to avoid spam
    private var lastCheckTime: Date = .distantPast
    
    /// Minimum interval between clipboard checks
    private let minimumCheckInterval: TimeInterval = 1.0
    
    private init() {}
    
    // MARK: - Public API
    
    /// Check clipboard for new content. Returns nil if no new content or privacy declined.
    /// Must be called from the keyboard's viewDidAppear or when the keyboard detects a paste action.
    func checkForNewClipboardContent() -> String? {
        // Respect minimum check interval
        guard Date().timeIntervalSince(lastCheckTime) >= minimumCheckInterval else { return nil }
        lastCheckTime = Date()
        
        // Check if clipboard content has changed
        let currentChangeCount = UIPasteboard.general.changeCount
        guard currentChangeCount != lastChangeCount else { return nil }
        lastChangeCount = currentChangeCount
        
        // Check opt-in status
        guard isOptedIn else {
            if !hasPrompted {
                // Return a signal that we need to show opt-in prompt
                // The caller should handle this
                return nil // Returning nil; caller checks hasPrompted
            }
            return nil
        }
        
        // Get clipboard content
        guard let content = UIPasteboard.general.string,
              !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        
        return content
    }
    
    /// Show the privacy opt-in alert on the provided view controller
    func requestPermission(on viewController: UIViewController) {
        guard !hasPrompted else { return }
        hasPrompted = true
        
        let alert = UIAlertController(
            title: "Smart Clipboard",
            message: "FlowLingo can detect when you copy text to show instant translation and analysis options.\n\n" +
                     "Your clipboard is only checked when the keyboard is active, and we never store or transmit " +
                     "clipboard content unless you manually tap \"Analyze.\"",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: "Enable",
            style: .default,
            handler: { [weak self] _ in
                self?.isOptedIn = true
                NotificationCenter.default.post(name: .clipboardPermissionChanged, object: nil)
            }
        ))
        
        alert.addAction(UIAlertAction(
            title: "Not Now",
            style: .cancel,
            handler: { [weak self] _ in
                self?.isOptedIn = false
                // Allow re-prompt later
                self?.hasPrompted = false
            }
        ))
        
        // Make alert accessible
        alert.view.accessibilityIdentifier = "ClipboardPermissionAlert"
        
        viewController.present(alert, animated: true)
    }
    
    /// User can toggle clipboard detection from settings
    func setOptedIn(_ optedIn: Bool) {
        isOptedIn = optedIn
        hasPrompted = true
    }
    
    var isClipboardDetectionEnabled: Bool {
        isOptedIn
    }
    
    /// Reset clipboard change count (call when keyboard is dismissed)
    func reset() {
        lastChangeCount = UIPasteboard.general.changeCount
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let clipboardPermissionChanged = Notification.Name("flowlingo.clipboardPermissionChanged")
    static let clipboardContentDetected = Notification.Name("flowlingo.clipboardContentDetected")
    static let didRequestAnalyze = Notification.Name("flowlingo.didRequestAnalyze")
}