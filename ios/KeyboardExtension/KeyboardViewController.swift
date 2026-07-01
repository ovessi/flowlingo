import UIKit

// MARK: - KeyboardViewController

/// The primary view controller for the FlowLingo keyboard extension.
///
/// Architecture:
/// ```
/// ┌────────────────────────────────────────────┐
/// │  AnalyzeBannerView (clipboard detection)   │ ← Optional
/// ├────────────────────────────────────────────┤
/// │  FlowBarView (language, tone, analyze,     │
/// │            settings)                       │ ← Always visible
/// ├────────────────────────────────────────────┤
/// │  StatusIndicatorView (thinking/offline)    │ ← Conditional
/// ├────────────────────────────────────────────┤
/// │  SuggestionChipsView (AI replies)          │ ← Conditional
/// ├────────────────────────────────────────────┤
/// │  KeyboardLayoutView (QWERTY keys)          │ ← Full keyboard
/// └────────────────────────────────────────────┘
/// ```
final class KeyboardViewController: UIInputViewController {
    
    // MARK: - Constants
    
    private enum Layout {
        static let flowBarHeight: CGFloat = 52
        static let bannerHeight: CGFloat = 44
        static let statusHeight: CGFloat = 32
        static let keyboardRowCount: CGFloat = 5
    }
    
    // MARK: - State
    
    private var keyboardState = KeyboardState.initial {
        didSet { updateUIForState() }
    }
    
    private var currentTone: Tone {
        get { keyboardState.currentTone }
        set {
            keyboardState.currentTone = newValue
            flowBar.currentTone = newValue
            HapticFeedbackService.shared.toggle()
        }
    }
    
    private var sourceLanguage: Language {
        get { keyboardState.sourceLanguage }
        set {
            keyboardState.sourceLanguage = newValue
            flowBar.sourceLanguage = newValue
            keyboardLayout.languageCode = newValue.code.uppercased()
        }
    }
    
    private var targetLanguage: Language {
        get { keyboardState.targetLanguage }
        set {
            keyboardState.targetLanguage = newValue
            flowBar.targetLanguage = newValue
        }
    }
    
    private var isShifted = false {
        didSet { keyboardLayout.isShifted = isShifted }
    }
    
    private var keyboardMode: KeyboardLayoutView.KeyboardMode = .letters {
        didSet { keyboardLayout.mode = keyboardMode }
    }
    
    private var isOnline = true {
        didSet {
            keyboardState.isOffline = !isOnline
            statusIndicator.state = isOnline ? .hidden : .offline
        }
    }
    
    // MARK: - Subviews
    
    private lazy var analyzeBanner: AnalyzeBannerView = {
        let view = AnalyzeBannerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onAnalyze = { [weak self] in self?.didRequestAnalyze() }
        view.onDismiss = { [weak self] in self?.dismissBanner() }
        return view
    }()
    
    private lazy var flowBar: FlowBarView = {
        let view = FlowBarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onLanguageTap = { [weak self] in self?.didTapLanguage() }
        view.onToneChanged = { [weak self] tone in self?.currentTone = tone }
        view.onAnalyzeTap = { [weak self] in self?.didRequestAnalyze() }
        view.onSettingsTap = { [weak self] in self?.didTapSettings() }
        return view
    }()
    
    private lazy var statusIndicator: StatusIndicatorView = {
        let view = StatusIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var suggestionChips: SuggestionChipsView = {
        let view = SuggestionChipsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onTapSuggestion = { [weak self] suggestion in
            self?.insertSuggestion(suggestion)
        }
        view.onLongPressSuggestion = { [weak self] suggestion in
            self?.previewSuggestion(suggestion)
        }
        return view
    }()
    
    private lazy var keyboardLayout: KeyboardLayoutView = {
        let view = KeyboardLayoutView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.languageCode = sourceLanguage.code.uppercased()
        view.onKeyTap = { [weak self] keyType in
            self?.handleKeyTap(keyType)
        }
        return view
    }()
    
    private let headerContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let mainContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Constraints
    
    private var bannerHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Services
    
    private let clipboardService = ClipboardDetectionService.shared
    private let mockService = MockAPIService.shared
    private let haptics = HapticFeedbackService.shared
    private let networkMonitor = NetworkMonitorService.shared
    
    // MARK: - Debounce
    
    private var translationWorkItem: DispatchWorkItem?
    private let translationDebounceInterval: TimeInterval = 0.4
    private var lastDetectedLanguage: String = "en"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboard()
        setupNotifications()
        requestClipboardPermissionIfNeeded()
        startNetworkMonitoring()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyTheme()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkClipboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        clipboardService.reset()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            applyTheme()
        }
    }
    
    // MARK: - Setup
    
    private func setupKeyboard() {
        view.backgroundColor = .clear
        
        // Build hierarchy: header on top, keyboard below
        headerContainer.addArrangedSubview(analyzeBanner)
        headerContainer.addArrangedSubview(flowBar)
        headerContainer.addArrangedSubview(statusIndicator)
        headerContainer.addArrangedSubview(suggestionChips)
        
        mainContainer.addArrangedSubview(headerContainer)
        mainContainer.addArrangedSubview(keyboardLayout)
        
        view.addSubview(mainContainer)
        
        NSLayoutConstraint.activate([
            mainContainer.topAnchor.constraint(equalTo: view.topAnchor),
            mainContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mainContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        // Fixed heights
        flowBar.heightAnchor.constraint(equalToConstant: Layout.flowBarHeight).isActive = true
        bannerHeightConstraint = analyzeBanner.heightAnchor.constraint(equalToConstant: Layout.bannerHeight)
        
        suggestionChips.isHidden = true
        statusIndicator.isHidden = true
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clipboardPermissionChanged),
            name: .clipboardPermissionChanged,
            object: nil
        )
    }
    
    // MARK: - Network Monitoring
    
    private func startNetworkMonitoring() {
        networkMonitor.onStatusChange = { [weak self] isConnected in
            DispatchQueue.main.async {
                self?.isOnline = isConnected
            }
        }
        isOnline = networkMonitor.isConnected
    }
    
    // MARK: - Permission
    
    private func requestClipboardPermissionIfNeeded() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            let hasPrompted = UserDefaults.standard.bool(forKey: "clipboard_has_prompted")
            guard !hasPrompted else { return }
            self.clipboardService.requestPermission(on: self)
        }
    }
    
    @objc private func clipboardPermissionChanged() {
        checkClipboard()
    }
    
    // MARK: - Clipboard
    
    private func checkClipboard() {
        guard clipboardService.isClipboardDetectionEnabled else { return }
        if let content = clipboardService.checkForNewClipboardContent() {
            keyboardState.clipboardText = content
            analyzeBanner.clipboardText = content
            bannerHeightConstraint?.isActive = true
            analyzeBanner.show()
        }
    }
    
    private func dismissBanner() {
        analyzeBanner.hide()
        keyboardState.clipboardText = nil
        bannerHeightConstraint?.isActive = false
    }
    
    // MARK: - Key Handling
    
    private func handleKeyTap(_ keyType: KeyboardKeyView.KeyType) {
        switch keyType {
        case .letter(let char):
            let charToInsert = isShifted ? char.uppercased() : char.lowercased()
            textDocumentProxy.insertText(charToInsert)
            haptics.keyPress()
            if isShifted && !isShiftLocked {
                isShifted = false
            }
            detectAndUpdateLanguage()
            
        case .space:
            textDocumentProxy.insertText(" ")
            haptics.keyPress()
            
        case .return:
            textDocumentProxy.insertText("\n")
            haptics.modifierKeyPress()
            
        case .backspace:
            textDocumentProxy.deleteBackward()
            haptics.modifierKeyPress()
            
        case .shift:
            isShifted.toggle()
            haptics.toggle()
            
        case .globe:
            haptics.toggle()
            advanceToNextInputMode()
            
        case .emoji:
            haptics.toggle()
            // In production: switch to an emoji keyboard layout
            
        case .number:
            keyboardMode = keyboardMode == .numbers ? .letters : .numbers
            isShifted = keyboardMode == .letters
            haptics.toggle()
            
        case .symbol:
            keyboardMode = keyboardMode == .symbols ? .letters : .symbols
            isShifted = keyboardMode == .letters
            haptics.toggle()
            
        case .numberPad:
            keyboardMode = .letters
            isShifted = false
            haptics.toggle()
            
        case .punctuation(let char):
            textDocumentProxy.insertText(String(char))
            haptics.keyPress()
            if keyboardMode != .letters {
                keyboardMode = .letters
            }
            detectAndUpdateLanguage()
            
        case .dismiss:
            haptics.toggle()
            dismissKeyboard()
            
        case .none:
            break
        }
    }
    
    private var isShiftLocked = false
    
    // MARK: - Real-time Language Detection
    
    private func detectAndUpdateLanguage() {
        translationWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.performLanguageDetection()
        }
        translationWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + translationDebounceInterval, execute: workItem)
    }
    
    private func performLanguageDetection() {
        guard let context = textDocumentProxy.documentContextBeforeInput,
              !context.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return }
        
        let detected = detectLanguage(text: context)
        
        // Only update if language changed
        if detected != lastDetectedLanguage && detected != "und" {
            lastDetectedLanguage = detected
            keyboardState.detectedSourceLang = detected
            
            // Auto-update source language if user types in a different language
            if let lang = Language.from(code: detected), lang != sourceLanguage {
                sourceLanguage = lang
                statusIndicator.state = .complete
                // Auto-dismiss after 1s
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    self?.statusIndicator.state = .hidden
                }
            }
        }
        
        // Check network while we're at it
        isOnline = networkMonitor.isConnected
    }
    
    // MARK: - AI Actions
    
    private func didRequestAnalyze() {
        haptics.toggle()
        
        guard isOnline else {
            statusIndicator.state = .error("No internet connection")
            return
        }
        
        let textToAnalyze: String
        
        if let clipboardText = keyboardState.clipboardText, !clipboardText.isEmpty {
            textToAnalyze = clipboardText
        } else if let context = textDocumentProxy.documentContextBeforeInput {
            textToAnalyze = context
        } else {
            statusIndicator.state = .error("No text to analyze")
            return
        }
        
        guard !textToAnalyze.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            statusIndicator.state = .error("No text to analyze")
            return
        }
        
        keyboardState.isAnalyzing = true
        statusIndicator.state = .thinking
        flowBar.isAnalyzing = true
        
        let detectedLang = detectLanguage(text: textToAnalyze)
        keyboardState.detectedSourceLang = detectedLang
        
        performAnalysis(text: textToAnalyze, detectedLang: detectedLang)
    }
    
    private func performAnalysis(text: String, detectedLang: String?) {
        Task { @MainActor in
            do {
                let targetLangCode = targetLanguage.code
                let response = try await mockService.analyze(
                    text: text,
                    language: detectedLang ?? targetLangCode
                )
                
                let suggestions = response.suggestedReplies.map {
                    AISuggestion(text: $0, confidence: Double.random(in: 0.75...0.95))
                }
                
                keyboardState.suggestionChips = suggestions
                keyboardState.isAnalyzing = false
                flowBar.isAnalyzing = false
                
                suggestionChips.suggestions = suggestions
                suggestionChips.isHidden = false
                
                statusIndicator.state = .complete
                HapticFeedbackService.shared.aiActionComplete()
                dismissBanner()
                
            } catch {
                keyboardState.isAnalyzing = false
                flowBar.isAnalyzing = false
                statusIndicator.state = .error(error.localizedDescription)
                HapticFeedbackService.shared.error()
            }
        }
    }
    
    // MARK: - Translation (from FlowBar translate action)
    
    private func performTranslation(text: String, sourceLang: String, targetLang: String, tone: Tone) {
        guard isOnline else {
            statusIndicator.state = .error("No internet connection")
            return
        }
        
        keyboardState.isAnalyzing = true
        statusIndicator.state = .thinking
        flowBar.isAnalyzing = true
        
        Task { @MainActor in
            do {
                let response = try await mockService.translate(
                    text: text,
                    sourceLang: sourceLang,
                    targetLang: targetLang,
                    tone: tone
                )
                
                // Replace text with translation
                textDocumentProxy.deleteBackward(times: text.count)
                textDocumentProxy.insertText(response.translatedText)
                
                keyboardState.isAnalyzing = false
                flowBar.isAnalyzing = false
                statusIndicator.state = .complete
                HapticFeedbackService.shared.aiActionComplete()
                suggestionChips.isHidden = true
                
            } catch {
                keyboardState.isAnalyzing = false
                flowBar.isAnalyzing = false
                statusIndicator.state = .error(error.localizedDescription)
                HapticFeedbackService.shared.error()
            }
        }
    }
    
    // MARK: - Text Change (Debounced Language Detection)
    
    override func textDidChange(_ textInput: UITextInput?) {
        super.textDidChange(textInput)
        detectAndUpdateLanguage()
    }
    
    // MARK: - Suggestions
    
    private func insertSuggestion(_ suggestion: AISuggestion) {
        haptics.suggestionTap()
        
        // Delete context text and insert the suggestion
        if let context = textDocumentProxy.documentContextBeforeInput {
            textDocumentProxy.deleteBackward(times: context.count)
        }
        textDocumentProxy.insertText(suggestion.text)
        
        suggestionChips.suggestions = []
        suggestionChips.isHidden = true
    }
    
    private func previewSuggestion(_ suggestion: AISuggestion) {
        haptics.longPressPreview()
        statusIndicator.state = .complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self, !self.keyboardState.isAnalyzing else { return }
            self.statusIndicator.state = self.isOnline ? .hidden : .offline
        }
    }
    
    // MARK: - Language Detection
    
    private func detectLanguage(text: String) -> String {
        MockAPIService.detectLanguage(text: text)
    }
    
    // MARK: - Navigation
    
    private func didTapLanguage() {
        haptics.toggle()
        let temp = sourceLanguage
        sourceLanguage = targetLanguage
        targetLanguage = temp
        statusIndicator.state = .complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self, !self.keyboardState.isAnalyzing else { return }
            self.statusIndicator.state = self.isOnline ? .hidden : .offline
        }
    }
    
    private func didTapSettings() {
        haptics.toggle()
        if let url = URL(string: "flowlingo://settings") {
            self.openURL?(url)
        }
    }
    
    // MARK: - Theme
    
    private func applyTheme() {
        let traitCollection = view.traitCollection
        flowBar.applyTheme(traitCollection: traitCollection)
        analyzeBanner.applyTheme(traitCollection: traitCollection)
        suggestionChips.applyTheme(traitCollection: traitCollection)
        keyboardLayout.applyTheme(traitCollection: traitCollection)
    }
    
    // MARK: - State UI Sync
    
    private func updateUIForState() {
        flowBar.isAnalyzing = keyboardState.isAnalyzing
        if keyboardState.isAnalyzing {
            statusIndicator.state = .thinking
        } else if keyboardState.isOffline {
            statusIndicator.state = .offline
        }
    }
    
    // MARK: - Memory
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        translationWorkItem?.cancel()
    }
}

// MARK: - Text Input Proxy Extensions

extension UITextDocumentProxy {
    func deleteBackward(times count: Int) {
        for _ in 0..<count {
            deleteBackward()
        }
    }
}

// MARK: - Network Monitor Service

final class NetworkMonitorService {
    static let shared = NetworkMonitorService()
    
    var onStatusChange: ((Bool) -> Void)?
    
    private(set) var isConnected = true {
        didSet {
            if oldValue != isConnected {
                onStatusChange?(isConnected)
            }
        }
    }
    
    private init() {
        // In production, use NWPathMonitor from Network.framework
        #if targetEnvironment(simulator)
        isConnected = true
        #else
        // Check connectivity periodically with a simple reachability test
        checkConnectivity()
        #endif
    }
    
    private func checkConnectivity() {
        // Simple connectivity check — in production, use NWPathMonitor
        isConnected = true // Optimistic by default
    }
}