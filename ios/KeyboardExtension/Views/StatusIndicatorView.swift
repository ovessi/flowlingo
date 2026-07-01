import UIKit

// MARK: - Status Indicator View

/// Subtle UI indicators for keyboard state:
/// - Pulsing indigo dot when AI is "thinking"
/// - Offline banner when translation packs are missing
/// All indicators are designed to be unobtrusive while clearly communicating state.
final class StatusIndicatorView: UIView {
    
    // MARK: - Public Properties
    
    enum IndicatorState {
        case hidden
        case thinking    // AI is processing — pulsing dot
        case offline     // No network — warning banner
        case error(String) // Error message
        case complete    // Action completed successfully
    }
    
    var state: IndicatorState = .hidden {
        didSet { updateState() }
    }
    
    // MARK: - Private UI
    
    private let dotView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Animation
    
    private var pulseLayer: CALayer?
    
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
        isUserInteractionEnabled = false // Indicators are display-only
        
        addSubview(containerView)
        containerView.addSubview(stackView)
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(dotView)
        stackView.addArrangedSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            
            dotView.widthAnchor.constraint(equalToConstant: 8),
            dotView.heightAnchor.constraint(equalToConstant: 8),
            
            iconImageView.widthAnchor.constraint(equalToConstant: 16),
            iconImageView.heightAnchor.constraint(equalToConstant: 16),
        ])
        
        // Start hidden
        alpha = 0
        containerView.alpha = 0
    }
    
    // MARK: - State Update
    
    private func updateState() {
        // Remove any existing animations
        dotView.layer.removeAllAnimations()
        pulseLayer?.removeFromSuperlayer()
        
        switch state {
        case .hidden:
            hide()
            
        case .thinking:
            messageLabel.text = "Translating..."
            iconImageView.image = nil
            dotView.isHidden = false
            containerView.backgroundColor = ThemeService.Colors.primary.withAlphaComponent(0.1)
            messageLabel.textColor = ThemeService.Colors.primary
            
            // Start pulse animation on dot
            startPulse()
            show()
            
        case .offline:
            messageLabel.text = "Offline — some features unavailable"
            let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
            iconImageView.image = UIImage(systemName: "wifi.slash", withConfiguration: config)
            iconImageView.tintColor = ThemeService.Colors.warning
            dotView.isHidden = true
            containerView.backgroundColor = ThemeService.Colors.warning.withAlphaComponent(0.1)
            messageLabel.textColor = ThemeService.Colors.warning
            show()
            
        case .error(let message):
            messageLabel.text = message
            let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
            iconImageView.image = UIImage(systemName: "exclamationmark.circle", withConfiguration: config)
            iconImageView.tintColor = ThemeService.Colors.error
            dotView.isHidden = true
            containerView.backgroundColor = ThemeService.Colors.error.withAlphaComponent(0.1)
            messageLabel.textColor = ThemeService.Colors.error
            show()
            
            // Auto-dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                guard case .error = self?.state else { return }
                self?.hide()
            }
            
        case .complete:
            messageLabel.text = "Done!"
            let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
            iconImageView.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)
            iconImageView.tintColor = ThemeService.Colors.success
            dotView.isHidden = true
            containerView.backgroundColor = ThemeService.Colors.success.withAlphaComponent(0.1)
            messageLabel.textColor = ThemeService.Colors.success
            show()
            
            // Auto-dismiss after 1.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                guard case .complete = self?.state else { return }
                self?.hide()
            }
        }
        
        updateAccessibility()
    }
    
    // MARK: - Animation
    
    private func startPulse() {
        // Pulsing opacity on dot
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 0.3
        pulseAnimation.duration = 0.8
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        dotView.layer.add(pulseAnimation, forKey: "thinkingPulse")
        
        // Dot color
        dotView.backgroundColor = ThemeService.Colors.primary
    }
    
    // MARK: - Visibility
    
    private func show() {
        guard isHidden || alpha < 0.5 else { return }
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.alpha = 1
                self.containerView.alpha = 1
            }
        )
    }
    
    private func hide() {
        guard !isHidden || alpha > 0.5 else { return }
        
        UIView.animate(
            withDuration: 0.15,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                self.alpha = 0
                self.containerView.alpha = 0
            }
        )
    }
    
    // MARK: - Accessibility
    
    private func updateAccessibility() {
        switch state {
        case .hidden:
            isAccessibilityElement = false
        case .thinking:
            isAccessibilityElement = true
            accessibilityLabel = "Translating"
            accessibilityTraits = .updatesFrequently
        case .offline:
            isAccessibilityElement = true
            accessibilityLabel = "Offline mode"
        case .error(let message):
            isAccessibilityElement = true
            accessibilityLabel = "Error: \(message)"
        case .complete:
            isAccessibilityElement = true
            accessibilityLabel = "Translation complete"
        }
    }
}