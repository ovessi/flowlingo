import UIKit

// MARK: - Settings Button View

/// Settings gear icon in the FlowBar.
/// Opens the companion app's settings or an in-keyboard quick settings panel.
final class SettingsButtonView: UIControl {
    
    // MARK: - Public Properties
    
    var onTap: (() -> Void)?
    
    // MARK: - Private UI
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        imageView.image = UIImage(systemName: "gearshape.fill", withConfiguration: config)
        return imageView
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
        accessibilityLabel = "Settings"
        accessibilityHint = "Opens FlowLingo settings"
        
        addSubview(iconImageView)
        
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
        ])
        
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
        
        updateDisplay(isDark: false)
    }
    
    // MARK: - Theme Update
    
    func applyTheme(traitCollection: UITraitCollection) {
        let isDark = traitCollection.userInterfaceStyle == .dark
        updateDisplay(isDark: isDark)
    }
    
    private func updateDisplay(isDark: Bool) {
        let color: UIColor = isDark
            ? ThemeService.Colors.Dark.textLow
            : ThemeService.Colors.Light.textLow
        iconImageView.tintColor = color
    }
    
    // MARK: - Actions
    
    @objc private func didTap() {
        HapticFeedbackService.shared.toggle()
        onTap?()
    }
    
    // MARK: - Hit Testing
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let expandedBounds = bounds.insetBy(dx: -8, dy: -8)
        return expandedBounds.contains(point)
    }
}