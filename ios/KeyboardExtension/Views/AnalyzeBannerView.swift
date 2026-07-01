import UIKit

// MARK: - Analyze Banner View

/// A compact banner that appears above the FlowBar when clipboard content is detected.
/// Shows a preview of the copied text with an "Analyze" button.
/// Respects privacy: only shows when user has opted into clipboard detection.
final class AnalyzeBannerView: UIView {
    
    // MARK: - Public Properties
    
    var clipboardText: String? {
        didSet { updateDisplay() }
    }
    
    var onAnalyze: (() -> Void)?
    var onDismiss: (() -> Void)?
    
    // MARK: - Private UI
    
    private let previewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.lineBreakMode = .middleTruncation
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private let analyzeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Analyze", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        return button
    }()
    
    private let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        button.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let backgroundView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .systemMaterial)
        let view = UIVisualEffectView(effect: effect)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
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
        
        addSubview(backgroundView)
        backgroundView.contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(dismissButton)
        stackView.addArrangedSubview(previewLabel)
        stackView.addArrangedSubview(analyzeButton)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
        ])
        
        // Button actions
        analyzeButton.addTarget(self, action: #selector(didTapAnalyze), for: .touchUpInside)
        dismissButton.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
        
        // Start hidden
        alpha = 0
        isHidden = true
        transform = CGAffineTransform(translationX: 0, y: -20)
        
        applyTheme(traitCollection: traitCollection)
    }
    
    // MARK: - Theme
    
    func applyTheme(traitCollection: UITraitCollection) {
        let isDark = traitCollection.userInterfaceStyle == .dark
        
        previewLabel.textColor = isDark
            ? ThemeService.Colors.Dark.textMid
            : ThemeService.Colors.Light.textMid
        
        backgroundView.effect = UIBlurEffect(style: isDark ? .systemUltraThinMaterialDark : .systemUltraThinMaterialLight)
        
        analyzeButton.backgroundColor = isDark
            ? ThemeService.Colors.primaryLight.withAlphaComponent(0.2)
            : ThemeService.Colors.primary.withAlphaComponent(0.15)
        
        analyzeButton.tintColor = isDark
            ? ThemeService.Colors.primaryLight
            : ThemeService.Colors.primary
        
        dismissButton.tintColor = isDark
            ? ThemeService.Colors.Dark.textLow
            : ThemeService.Colors.Light.textLow
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            applyTheme(traitCollection: traitCollection)
        }
    }
    
    // MARK: - Display
    
    private func updateDisplay() {
        guard let text = clipboardText, !text.isEmpty else {
            hide()
            return
        }
        
        // Show first 60 characters of the clipboard content
        let preview = text.count > 60 ? String(text.prefix(60)) + "…" : text
        previewLabel.text = "\"\(preview)\""
        
        isAccessibilityElement = false
        previewLabel.isAccessibilityElement = true
        previewLabel.accessibilityLabel = "Clipboard content: \(preview)"
        analyzeButton.accessibilityLabel = "Analyze clipboard text"
        dismissButton.accessibilityLabel = "Dismiss clipboard banner"
        
        show()
    }
    
    // MARK: - Visibility
    
    func show(animated: Bool = true) {
        guard isHidden || alpha < 1 else { return }
        
        isHidden = false
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.6,
            options: .curveEaseOut,
            animations: {
                self.alpha = 1
                self.transform = .identity
            }
        )
    }
    
    func hide(animated: Bool = true) {
        guard !isHidden || alpha > 0 else { return }
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                self.alpha = 0
                self.transform = CGAffineTransform(translationX: 0, y: -20)
            },
            completion: { _ in
                self.isHidden = true
                self.transform = .identity
            }
        )
    }
    
    // MARK: - Actions
    
    @objc private func didTapAnalyze() {
        HapticFeedbackService.shared.toggle()
        onAnalyze?()
    }
    
    @objc private func didTapDismiss() {
        HapticFeedbackService.shared.toggle()
        hide()
        onDismiss?()
    }
}