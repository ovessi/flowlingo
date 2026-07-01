import UIKit

// MARK: - Analyze Button View

/// The "sparkle" analyze button in the FlowBar.
/// Triggers AI analysis of the current text or clipboard content.
/// Shows a subtle animation/pulse when AI is processing.
final class AnalyzeButtonView: UIControl {
    
    // MARK: - Public Properties
    
    var isProcessing: Bool = false {
        didSet {
            updateProcessingState()
        }
    }
    
    var onTap: (() -> Void)?
    
    // MARK: - Private UI
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        imageView.image = UIImage(systemName: "sparkle.magnifyingglass", withConfiguration: config)
        return imageView
    }()
    
    private let pulseView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 18
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        return view
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Animation Properties
    
    private var pulseAnimation: CAAnimation?
    
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
        accessibilityLabel = "Analyze text"
        accessibilityHint = "Analyzes the current text for translation, cultural context, and suggested replies"
        
        addSubview(pulseView)
        addSubview(iconImageView)
        addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            pulseView.centerXAnchor.constraint(equalTo: centerXAnchor),
            pulseView.centerYAnchor.constraint(equalTo: centerYAnchor),
            pulseView.widthAnchor.constraint(equalToConstant: 36),
            pulseView.heightAnchor.constraint(equalToConstant: 36),
            
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),
            
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
        
        updateDisplay(isDark: false)
    }
    
    // MARK: - Theme Update
    
    func applyTheme(traitCollection: UITraitCollection) {
        let isDark = traitCollection.userInterfaceStyle == .dark
        updateDisplay(isDark: isDark)
        
        if isDark {
            activityIndicator.style = .medium
            activityIndicator.color = .white
        } else {
            activityIndicator.style = .medium
            activityIndicator.color = .white
        }
    }
    
    private func updateDisplay(isDark: Bool) {
        let tintColor: UIColor = isDark
            ? ThemeService.Colors.primaryLight
            : ThemeService.Colors.primary
        
        iconImageView.tintColor = tintColor
        pulseView.backgroundColor = tintColor.withAlphaComponent(0.15)
    }
    
    // MARK: - Processing State
    
    private func updateProcessingState() {
        if isProcessing {
            iconImageView.isHidden = true
            activityIndicator.startAnimating()
            isUserInteractionEnabled = false
            accessibilityLabel = "Analyzing..."
            startPulseAnimation()
        } else {
            iconImageView.isHidden = false
            activityIndicator.stopAnimating()
            isUserInteractionEnabled = true
            accessibilityLabel = "Analyze text"
            stopPulseAnimation()
        }
    }
    
    private func startPulseAnimation() {
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 1.0
        pulse.toValue = 1.15
        pulse.duration = 0.6
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        pulseView.layer.add(pulse, forKey: "pulse")
        pulseView.alpha = 1
    }
    
    private func stopPulseAnimation() {
        pulseView.layer.removeAnimation(forKey: "pulse")
        
        UIView.animate(withDuration: 0.2) {
            self.pulseView.alpha = 0
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTap() {
        guard !isProcessing else { return }
        HapticFeedbackService.shared.toggle()
        
        // Brief scale animation on tap
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        })
        
        onTap?()
    }
    
    // MARK: - Hit Testing
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let expandedBounds = bounds.insetBy(dx: -8, dy: -8)
        return expandedBounds.contains(point)
    }
}