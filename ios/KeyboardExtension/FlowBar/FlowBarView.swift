import UIKit

// MARK: - FlowBar View

/// The floating action bar above keyboard keys — the primary UI surface for FlowLingo's smart features.
///
/// Layout (left-to-right in LTR, mirrored in RTL):
/// [Language Selector] ...[Tone Toggle] ...[Analyze Button] ...[Settings]
///
/// Key behaviors:
/// - Auto-hides when the keyboard is dismissed
/// - 200ms ease-in-out appearance/disappearance
/// - Respects Dynamic Type and Dark/Light mode
/// - Full RTL support
final class FlowBarView: UIView {
    
    // MARK: - Public Properties
    
    var currentTone: Tone = .casual {
        didSet { toneToggle.currentTone = currentTone }
    }
    
    var sourceLanguage: Language = .english {
        didSet { languageSelector.sourceLanguage = sourceLanguage }
    }
    
    var targetLanguage: Language = .spanish {
        didSet { languageSelector.targetLanguage = targetLanguage }
    }
    
    var isAnalyzing: Bool = false {
        didSet { analyzeButton.isProcessing = isAnalyzing }
    }
    
    var onLanguageTap: (() -> Void)?
    var onToneChanged: ((Tone) -> Void)?
    var onAnalyzeTap: (() -> Void)?
    var onSettingsTap: (() -> Void)?
    
    // MARK: - Subviews
    
    private(set) lazy var languageSelector: LanguageSelectorView = {
        let view = LanguageSelectorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onTap = { [weak self] in self?.onLanguageTap?() }
        return view
    }()
    
    private(set) lazy var toneToggle: ToneToggleView = {
        let view = ToneToggleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onToneChanged = { [weak self] tone in self?.onToneChanged?(tone) }
        return view
    }()
    
    private(set) lazy var analyzeButton: AnalyzeButtonView = {
        let view = AnalyzeButtonView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onTap = { [weak self] in self?.onAnalyzeTap?() }
        return view
    }()
    
    private(set) lazy var settingsButton: SettingsButtonView = {
        let view = SettingsButtonView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onTap = { [weak self] in self?.onSettingsTap?() }
        return view
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let backgroundBlurView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemMaterial)
        let view = UIVisualEffectView(effect: effect)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    // MARK: - Layout
    
    private let spacerView = UIView()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        clipsToBounds = true
        layer.cornerRadius = 12
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // Add blur background
        addSubview(backgroundBlurView)
        
        // Add separator line at bottom
        addSubview(separatorView)
        
        // Build layout
        let leadingSpacer = UIView()
        leadingSpacer.translatesAutoresizingMaskIntoConstraints = false
        leadingSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let trailingSpacer = UIView()
        trailingSpacer.translatesAutoresizingMaskIntoConstraints = false
        trailingSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let mainStack = UIStackView(arrangedSubviews: [
            leadingSpacer,
            languageSelector,
            toneToggle,
            analyzeButton,
            settingsButton,
            trailingSpacer,
        ])
        mainStack.axis = .horizontal
        mainStack.alignment = .center
        mainStack.distribution = .equalCentering
        mainStack.spacing = 8
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            // Background blur fills entire bar
            backgroundBlurView.topAnchor.constraint(equalTo: topAnchor),
            backgroundBlurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundBlurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundBlurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            // Separator at bottom
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: ThemeService.Layout.separatorHeight),
            
            // Main stack
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ThemeService.Layout.padding),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ThemeService.Layout.padding),
            
            // Equal sizing for button elements
            languageSelector.heightAnchor.constraint(equalToConstant: 32),
            toneToggle.widthAnchor.constraint(equalToConstant: 40),
            toneToggle.heightAnchor.constraint(equalToConstant: 36),
            analyzeButton.widthAnchor.constraint(equalToConstant: 40),
            analyzeButton.heightAnchor.constraint(equalToConstant: 40),
            settingsButton.widthAnchor.constraint(equalToConstant: 32),
            settingsButton.heightAnchor.constraint(equalToConstant: 32),
        ])
        
        applyTheme(traitCollection: traitCollection)
    }
    
    // MARK: - Theme
    
    func applyTheme(traitCollection: UITraitCollection) {
        let isDark = traitCollection.userInterfaceStyle == .dark
        
        separatorView.backgroundColor = isDark
            ? ThemeService.Colors.Dark.separator
            : ThemeService.Colors.Light.separator
        
        // Update blur style
        backgroundBlurView.effect = UIBlurEffect(style: isDark ? .systemUltraThinMaterialDark : .systemUltraThinMaterialLight)
        
        // Update subviews
        languageSelector.applyTheme(traitCollection: traitCollection)
        toneToggle.applyTheme(traitCollection: traitCollection)
        analyzeButton.applyTheme(traitCollection: traitCollection)
        settingsButton.applyTheme(traitCollection: traitCollection)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            applyTheme(traitCollection: traitCollection)
        }
    }
    
    // MARK: - Visibility
    
    func show(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard isHidden || alpha < 1 else { return }
        
        if animated {
            alpha = 0
            isHidden = false
            transform = CGAffineTransform(translationX: 0, y: -10)
            
            UIView.animate(
                withDuration: 0.2,
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 0.5,
                options: .curveEaseOut,
                animations: {
                    self.alpha = 1
                    self.transform = .identity
                },
                completion: { _ in completion?() }
            )
        } else {
            alpha = 1
            isHidden = false
            transform = .identity
            completion?()
        }
    }
    
    func hide(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard !isHidden || alpha > 0 else { return }
        
        if animated {
            UIView.animate(
                withDuration: 0.15,
                delay: 0,
                options: .curveEaseIn,
                animations: {
                    self.alpha = 0
                    self.transform = CGAffineTransform(translationX: 0, y: -8)
                },
                completion: { _ in
                    self.isHidden = true
                    self.transform = .identity
                    completion?()
                }
            )
        } else {
            alpha = 0
            isHidden = true
            transform = .identity
            completion?()
        }
    }
}