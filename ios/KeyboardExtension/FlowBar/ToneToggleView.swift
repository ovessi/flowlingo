import UIKit

// MARK: - Tone Toggle View

/// Cycling tone selector for the FlowBar.
/// Displays current tone as an SF Symbol icon.
/// Cycles through tones: Formal → Casual → Friendly → Urgent → Formal...
/// Light tap feedback on each toggle.
final class ToneToggleView: UIControl {
    
    // MARK: - Public Properties
    
    var currentTone: Tone = .casual {
        didSet {
            updateDisplay()
            sendActions(for: .valueChanged)
        }
    }
    
    var onToneChanged: ((Tone) -> Void)?
    
    // MARK: - Private UI
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        return label
    }()
    
    private let containerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 1
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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
        accessibilityHint = "Double-tap to cycle through tone: Formal, Casual, Friendly, Urgent"
        
        addSubview(containerStack)
        containerStack.addArrangedSubview(iconImageView)
        containerStack.addArrangedSubview(label)
        
        NSLayoutConstraint.activate([
            containerStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 4),
            containerStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -4),
            
            iconImageView.heightAnchor.constraint(equalToConstant: 18),
            iconImageView.widthAnchor.constraint(equalToConstant: 18),
        ])
        
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
        
        // Long press to show menu
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        longPress.minimumPressDuration = 0.5
        addGestureRecognizer(longPress)
        
        updateDisplay()
    }
    
    // MARK: - Theme Update
    
    func applyTheme(traitCollection: UITraitCollection) {
        let tintColor: UIColor = traitCollection.userInterfaceStyle == .dark
            ? ThemeService.Colors.primaryLight
            : ThemeService.Colors.primary
        
        let textLow = traitCollection.userInterfaceStyle == .dark
            ? ThemeService.Colors.Dark.textLow
            : ThemeService.Colors.Light.textLow
        
        iconImageView.tintColor = tintColor
        label.textColor = textLow
    }
    
    // MARK: - Display Update
    
    private func updateDisplay() {
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        iconImageView.image = UIImage(systemName: currentTone.systemSymbol, withConfiguration: config)
        label.text = currentTone.displayName
        accessibilityLabel = "Tone: \(currentTone.displayName)"
    }
    
    // MARK: - Actions
    
    @objc private func didTap() {
        HapticFeedbackService.shared.toggle()
        
        // Cycle to next tone
        let allTones = Tone.allCases
        guard let currentIndex = allTones.firstIndex(of: currentTone) else { return }
        let nextIndex = (currentIndex + 1) % allTones.count
        currentTone = allTones[nextIndex]
        onToneChanged?(currentTone)
    }
    
    @objc private func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        HapticFeedbackService.shared.longPressPreview()
        
        // Show tone picker as a context menu
        // In production, this would show UIMenu or a custom popover
        // For now, cycle as tap does but also post notification
        didTap()
    }
    
    // MARK: - Hit Testing
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let expandedBounds = bounds.insetBy(dx: -4, dy: -4)
        return expandedBounds.contains(point)
    }
}