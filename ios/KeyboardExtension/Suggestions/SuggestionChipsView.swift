import UIKit

// MARK: - Suggestion Chips View

/// Horizontally scrolling collection of AI-suggested reply chips.
/// Each chip is a pill-shaped button with the suggested text.
/// - Tap to insert the reply into the text field
/// - Long-press to preview the translation
final class SuggestionChipsView: UIView {
    
    // MARK: - Public Properties
    
    var suggestions: [AISuggestion] = [] {
        didSet { rebuildChips() }
    }
    
    var onTapSuggestion: ((AISuggestion) -> Void)?
    var onLongPressSuggestion: ((AISuggestion) -> Void)?
    
    var isVisible: Bool {
        !suggestions.isEmpty
    }
    
    // MARK: - Private UI
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.clipsToBounds = true
        scroll.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.decelerationRate = .fast
        return scroll
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Suggestions"
        label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        return label
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
        addSubview(separatorView)
        addSubview(titleLabel)
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: topAnchor),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            
            titleLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            scrollView.heightAnchor.constraint(equalToConstant: 38),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
        ])
        
        applyTheme(traitCollection: traitCollection)
    }
    
    // MARK: - Theme
    
    func applyTheme(traitCollection: UITraitCollection) {
        let isDark = traitCollection.userInterfaceStyle == .dark
        
        titleLabel.textColor = isDark
            ? ThemeService.Colors.Dark.textLow
            : ThemeService.Colors.Light.textLow
        
        separatorView.backgroundColor = isDark
            ? ThemeService.Colors.Dark.separator
            : ThemeService.Colors.Light.separator
        
        // Update existing chips
        for case let chip as SuggestionChip in stackView.arrangedSubviews {
            chip.applyTheme(traitCollection: traitCollection)
        }
    }
    
    // MARK: - Chip Building
    
    private func rebuildChips() {
        // Remove existing chips
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        // Add new chips
        for suggestion in suggestions {
            let chip = SuggestionChip(suggestion: suggestion)
            chip.translatesAutoresizingMaskIntoConstraints = false
            chip.onTap = { [weak self] in
                self?.onTapSuggestion?(suggestion)
            }
            chip.onLongPress = { [weak self] in
                self?.onLongPressSuggestion?(suggestion)
            }
            chip.applyTheme(traitCollection: traitCollection)
            stackView.addArrangedSubview(chip)
        }
        
        // Show/hide based on content
        let hasContent = !suggestions.isEmpty
        titleLabel.isHidden = !hasContent
        
        if hasContent {
            alpha = 1
            isHidden = false
        } else {
            alpha = 0
            isHidden = true
        }
    }
}

// MARK: - Suggestion Chip (Individual)

fileprivate final class SuggestionChip: UIControl {
    
    let suggestion: AISuggestion
    var onTap: (() -> Void)?
    var onLongPress: (() -> Void)?
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    init(suggestion: AISuggestion) {
        self.suggestion = suggestion
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        layer.cornerRadius = 17
        clipsToBounds = true
        
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 7),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -7),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
        ])
        
        label.text = suggestion.text
        isAccessibilityElement = true
        accessibilityLabel = "Suggested reply: \(suggestion.text)"
        accessibilityHint = "Double-tap to insert. Long-press to preview translation."
        
        addTarget(self, action: #selector(didTap), for: .touchUpInside)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        longPress.minimumPressDuration = 0.4
        addGestureRecognizer(longPress)
    }
    
    func applyTheme(traitCollection: UITraitCollection) {
        let isDark = traitCollection.userInterfaceStyle == .dark
        
        backgroundColor = isDark
            ? ThemeService.Colors.Dark.border.withAlphaComponent(0.3)
            : ThemeService.Colors.Light.surface
        
        label.textColor = isDark
            ? ThemeService.Colors.Dark.textHigh
            : ThemeService.Colors.Light.textHigh
        
        layer.borderWidth = 1
        layer.borderColor = (isDark
            ? ThemeService.Colors.Dark.border
            : ThemeService.Colors.Light.border
        ).cgColor
    }
    
    @objc private func didTap() {
        HapticFeedbackService.shared.suggestionTap()
        
        // Press animation
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
            self.alpha = 0.8
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
                self.alpha = 1
            }
        })
        
        onTap?()
    }
    
    @objc private func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        HapticFeedbackService.shared.longPressPreview()
        onLongPress?()
    }
    
    override var intrinsicContentSize: CGSize {
        let textSize = (suggestion.text as NSString).size(withAttributes: [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium)
        ])
        return CGSize(
            width: textSize.width + 28,
            height: 34
        )
    }
}