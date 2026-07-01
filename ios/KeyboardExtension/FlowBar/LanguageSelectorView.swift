import UIKit

// MARK: - Language Selector View

/// Displays source → target language pair with tap interaction.
/// Compact, elegant — fits in the FlowBar without overwhelming.
/// Supports RTL languages by mirroring the layout direction.
final class LanguageSelectorView: UIControl {
    
    // MARK: - Public Properties
    
    var sourceLanguage: Language = .english {
        didSet { updateDisplay() }
    }
    
    var targetLanguage: Language = .spanish {
        didSet { updateDisplay() }
    }
    
    var onTap: (() -> Void)?
    
    // MARK: - Private UI
    
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let arrowLabel: UILabel = {
        let label = UILabel()
        label.text = "→"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let targetLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let containerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 4
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
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
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityHint = "Double-tap to change language pair"
        
        addSubview(backgroundView)
        addSubview(containerStack)
        
        containerStack.addArrangedSubview(sourceLabel)
        containerStack.addArrangedSubview(arrowLabel)
        containerStack.addArrangedSubview(targetLabel)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            containerStack.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            containerStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            containerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            containerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
        ])
        
        // Add tap gesture
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
        
        updateDisplay()
    }
    
    // MARK: - Theme Update
    
    func applyTheme(traitCollection: UITraitCollection) {
        backgroundColor = .clear
        
        let surface = traitCollection.userInterfaceStyle == .dark
            ? ThemeService.Colors.Dark.surface
            : ThemeService.Colors.Light.surface
        
        let textHigh = traitCollection.userInterfaceStyle == .dark
            ? ThemeService.Colors.Dark.textHigh
            : ThemeService.Colors.Light.textHigh
        
        let textLow = traitCollection.userInterfaceStyle == .dark
            ? ThemeService.Colors.Dark.textLow
            : ThemeService.Colors.Light.textLow
        
        let tintColor: UIColor = traitCollection.userInterfaceStyle == .dark
            ? ThemeService.Colors.primaryLight
            : ThemeService.Colors.primary
        
        backgroundView.backgroundColor = surface
        
        sourceLabel.textColor = textHigh
        arrowLabel.textColor = tintColor
        targetLabel.textColor = textHigh
        
        // Update accessibility
        updateAccessibilityLabel()
    }
    
    // MARK: - Display Update
    
    private func updateDisplay() {
        sourceLabel.text = sourceLanguage.code.uppercased()
        targetLabel.text = targetLanguage.code.uppercased()
        
        // Handle RTL support
        let isRTL = sourceLanguage.isRTL || targetLanguage.isRTL
        if isRTL {
            arrowLabel.text = "←"
            containerStack.semanticContentAttribute = .forceRightToLeft
        } else {
            arrowLabel.text = "→"
            containerStack.semanticContentAttribute = .unspecified
        }
        
        updateAccessibilityLabel()
    }
    
    private func updateAccessibilityLabel() {
        accessibilityLabel = "From \(sourceLanguage.name) to \(targetLanguage.name)"
    }
    
    // MARK: - Actions
    
    @objc private func didTap() {
        HapticFeedbackService.shared.toggle()
        onTap?()
    }
    
    // MARK: - Hit Testing
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // Expand hit area for easier tapping
        let expandedBounds = bounds.insetBy(dx: -8, dy: -4)
        return expandedBounds.contains(point)
    }
}