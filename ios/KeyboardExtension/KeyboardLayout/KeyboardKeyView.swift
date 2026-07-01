import UIKit

// MARK: - Keyboard Key View

/// A single key on the FlowLingo keyboard. Renders as a pill-shaped button.
/// Supports: regular letters, shift (caps), backspace, return, space bar with indicator, globe, emoji toggle.
/// Matches iOS design — subtle shadows, correct insets, haptic feedback.
final class KeyboardKeyView: UIControl {
    
    // MARK: - Key Types
    
    enum KeyType: Equatable {
        case letter(Character)
        case shift
        case backspace
        case `return`
        case space(languageCode: String)
        case globe
        case emoji
        case number
        case symbol
        case numberPad
        case punctuation(Character)
        case dismiss
        case none
        
        var isSpecial: Bool {
            switch self {
            case .letter, .punctuation, .none: return false
            default: return true
            }
        }
        
        var isSticky: Bool {
            switch self {
            case .shift, .number, .symbol: return true
            default: return false
            }
        }
    }
    
    // MARK: - Properties
    
    let keyType: KeyType
    var isPressed: Bool = false { didSet { updatePressedState() } }
    var isShifted: Bool = false { didSet { updateDisplay() } }
    var customWidth: CGFloat?
    
    var onKeyTap: ((KeyType) -> Void)?
    
    // MARK: - UI
    
    private let label: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.adjustsFontForContentSizeCategory = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let backgroundLayer: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 6
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    // MARK: - Init
    
    init(type: KeyType) {
        self.keyType = type
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) { nil }
    
    private func setupView() {
        addSubview(backgroundLayer)
        addSubview(label)
        addSubview(iconView)
        
        NSLayoutConstraint.activate([
            backgroundLayer.topAnchor.constraint(equalTo: topAnchor, constant: 3),
            backgroundLayer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3),
            backgroundLayer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            backgroundLayer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),
        ])
        
        isAccessibilityElement = true
        addTarget(self, action: #selector(didTouchDown), for: .touchDown)
        addTarget(self, action: #selector(didTouchUpInside), for: .touchUpInside)
        addTarget(self, action: #selector(didTouchUpOutside), for: .touchUpOutside)
        addTarget(self, action: #selector(didTouchDragExit), for: .touchDragExit)
        
        updateDisplay()
    }
    
    // MARK: - Display
    
    func updateDisplay() {
        let isDark = traitCollection.userInterfaceStyle == .dark
        
        switch keyType {
        case .letter(let char):
            let displayChar = isShifted ? char.uppercased() : char.lowercased()
            label.text = String(displayChar)
            label.font = .systemFont(ofSize: 20, weight: .regular)
            label.isHidden = false
            iconView.isHidden = true
            
        case .space(let code):
            label.text = "Space"
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.isHidden = false
            iconView.isHidden = true
            // Add language indicator as a small badge
            let langBadge = UILabel(frame: CGRect(x: 0, y: 0, width: 28, height: 14))
            langBadge.text = code.uppercased()
            langBadge.font = .systemFont(ofSize: 9, weight: .bold)
            langBadge.textAlignment = .center
            langBadge.backgroundColor = isDark ? UIColor.white.withAlphaComponent(0.15) : UIColor.black.withAlphaComponent(0.08)
            langBadge.layer.cornerRadius = 3
            langBadge.clipsToBounds = true
            langBadge.translatesAutoresizingMaskIntoConstraints = false
            // We'll add this in configureForSpace()
            // But space key is special - show language code
            label.text = code.uppercased()
            
        case .return:
            label.text = "return"
            label.font = .systemFont(ofSize: 14, weight: .semibold)
            label.isHidden = false
            iconView.isHidden = true
            
        case .shift:
            label.isHidden = true
            iconView.isHidden = false
            let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
            iconView.image = UIImage(systemName: isShifted ? "shift.fill" : "shift", withConfiguration: config)
            
        case .backspace:
            label.isHidden = true
            iconView.isHidden = false
            let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
            iconView.image = UIImage(systemName: "delete.left", withConfiguration: config)
            
        case .globe:
            label.isHidden = true
            iconView.isHidden = false
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
            iconView.image = UIImage(systemName: "globe", withConfiguration: config)
            
        case .emoji:
            label.isHidden = true
            iconView.isHidden = false
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
            iconView.image = UIImage(systemName: "face.smiling", withConfiguration: config)
            
        case .number:
            label.text = "123"
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.isHidden = false
            iconView.isHidden = true
            
        case .symbol:
            label.text = "#+="
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.isHidden = false
            iconView.isHidden = true
            
        case .numberPad:
            label.text = ".?123"
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.isHidden = false
            iconView.isHidden = true
            
        case .punctuation(let char):
            label.text = String(char)
            label.font = .systemFont(ofSize: 20, weight: .regular)
            label.isHidden = false
            iconView.isHidden = true
            
        case .dismiss:
            label.isHidden = true
            iconView.isHidden = false
            let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
            iconView.image = UIImage(systemName: "keyboard.chevron.compact.down", withConfiguration: config)
            
        case .none:
            label.isHidden = true
            iconView.isHidden = true
        }
        
        applyTheme(traitCollection: traitCollection)
        updateAccessibility()
    }
    
    func applyTheme(traitCollection: UITraitCollection) {
        let isDark = traitCollection.userInterfaceStyle == .dark
        
        switch keyType {
        case .space, .return, .number, .symbol, .numberPad, .shift, .globe, .emoji, .dismiss:
            // Special keys: slightly darker
            backgroundLayer.backgroundColor = isDark
                ? UIColor(white: 0.25, alpha: 1.0)
                : UIColor(white: 0.82, alpha: 1.0)
            label.textColor = isDark ? .white : .black
            iconView.tintColor = isDark ? .white : .black
            
        case .backspace:
            backgroundLayer.backgroundColor = isDark
                ? UIColor(white: 0.25, alpha: 1.0)
                : UIColor(white: 0.82, alpha: 1.0)
            label.textColor = isDark ? .white : .black
            iconView.tintColor = isDark ? .white : .black
            
        default:
            // Regular keys
            backgroundLayer.backgroundColor = isDark
                ? UIColor(white: 0.35, alpha: 1.0)
                : UIColor(white: 0.99, alpha: 1.0)
            label.textColor = isDark ? .white : .black
            iconView.tintColor = isDark ? .white : .black
        }
        
        // Add subtle shadow for depth
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = isDark ? 0.2 : 0.1
        layer.shadowOffset = CGSize(width: 0, height: 0.5)
        layer.shadowRadius = 0.5
    }
    
    // MARK: - Press State
    
    private func updatePressedState() {
        let scale: CGFloat = isPressed ? 0.92 : 1.0
        let alpha: CGFloat = isPressed ? 0.7 : 1.0
        
        UIView.animate(withDuration: 0.08, delay: 0, options: .curveEaseOut) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.backgroundLayer.alpha = alpha
        }
        
        if isPressed {
            HapticFeedbackService.shared.keyPress()
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTouchDown() {
        isPressed = true
    }
    
    @objc private func didTouchUpInside() {
        isPressed = false
        onKeyTap?(keyType)
    }
    
    @objc private func didTouchUpOutside() {
        isPressed = false
    }
    
    @objc private func didTouchDragExit() {
        isPressed = false
    }
    
    // MARK: - Accessibility
    
    private func updateAccessibility() {
        switch keyType {
        case .letter(let c):
            accessibilityLabel = isShifted ? String(c).uppercased() : String(c).lowercased()
            accessibilityTraits = .keyboardKey
        case .shift:
            accessibilityLabel = isShifted ? "Shift on" : "Shift off"
            accessibilityTraits = .keyboardKey
        case .backspace:
            accessibilityLabel = "Delete"
            accessibilityTraits = .keyboardKey
        case .space:
            accessibilityLabel = "Space"
            accessibilityTraits = .keyboardKey
        case .return:
            accessibilityLabel = "Return"
            accessibilityTraits = .keyboardKey
        case .globe:
            accessibilityLabel = "Next keyboard"
            accessibilityTraits = .keyboardKey
        case .emoji:
            accessibilityLabel = "Emoji"
            accessibilityTraits = .keyboardKey
        case .dismiss:
            accessibilityLabel = "Dismiss keyboard"
            accessibilityTraits = .keyboardKey
        default:
            accessibilityLabel = label.text
            accessibilityTraits = .keyboardKey
        }
    }
}