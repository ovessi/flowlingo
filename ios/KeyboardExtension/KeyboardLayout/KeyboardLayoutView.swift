import UIKit

// MARK: - Keyboard Layout View

/// The full QWERTY keyboard layout with number row, shift, backspace, space bar (with language indicator),
/// return, globe, and emoji toggle. Supports symbols layer via mode toggling.
///
/// Layout:
/// ```
/// Row 0: [1] [2] [3] [4] [5] [6] [7] [8] [9] [0]
/// Row 1: [Q] [W] [E] [R] [T] [Y] [U] [I] [O] [P]
/// Row 2: [A] [S] [D] [F] [G] [H] [J] [K] [L]
/// Row 3: [⇧] [Z] [X] [C] [V] [B] [N] [M] [⌫]
/// Row 4: [123] [🌐] [____Space EN____] [return]
/// ```
final class KeyboardLayoutView: UIView {
    
    // MARK: - Public Properties
    
    var onKeyTap: ((KeyboardKeyView.KeyType) -> Void)?
    var languageCode: String = "EN" { didSet { updateSpaceKey() } }
    var isShifted: Bool = false { didSet { updateShiftState() } }
    var mode: KeyboardMode = .letters { didSet { rebuildKeys() } }
    
    enum KeyboardMode {
        case letters
        case numbers
        case symbols
    }
    
    // MARK: - Private
    
    private let stackView: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.alignment = .fill
        s.distribution = .fillEqually
        s.spacing = 0
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    private weak var spaceKey: KeyboardKeyView?
    private weak var shiftKey: KeyboardKeyView?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) { nil }
    
    private func setupView() {
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        rebuildKeys()
    }
    
    // MARK: - Key Rows
    
    private func rebuildKeys() {
        // Remove existing rows
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        let rows: [UIView]
        switch mode {
        case .letters:
            rows = buildLetterRows()
        case .numbers:
            rows = buildNumberRows()
        case .symbols:
            rows = buildSymbolRows()
        }
        
        for row in rows {
            stackView.addArrangedSubview(row)
        }
    }
    
    private func makeRow(_ keys: [KeyboardKeyView.KeyType], flexIndices: Set<Int> = []) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .fill
        row.distribution = .fillProportionally
        row.spacing = 0
        row.translatesAutoresizingMaskIntoConstraints = false
        
        for (index, keyType) in keys.enumerated() {
            let key = KeyboardKeyView(type: keyType)
            key.onKeyTap = { [weak self] type in self?.onKeyTap?(type) }
            key.translatesAutoresizingMaskIntoConstraints = false
            row.addArrangedSubview(key)
            
            if keyType == .space("EN") {
                spaceKey = key
            }
            if keyType == .shift {
                shiftKey = key
            }
        }
        
        return row
    }
    
    // MARK: - Letter Rows
    
    private func buildLetterRows() -> [UIView] {
        let numberRow = makeRow([
            .number, .punctuation("-"), .punctuation("/"), .punctuation(":"),
            .punctuation(";"), .punctuation("("), .punctuation(")"),
            .punctuation("$"), .punctuation("&"), .punctuation("@"),
            .punctuation("\""), .backspace
        ])
        
        let qRow = makeRow([
            .letter("q"), .letter("w"), .letter("e"), .letter("r"),
            .letter("t"), .letter("y"), .letter("u"), .letter("i"),
            .letter("o"), .letter("p")
        ])
        
        let aRow = makeRow([
            .letter("a"), .letter("s"), .letter("d"), .letter("f"),
            .letter("g"), .letter("h"), .letter("j"), .letter("k"),
            .letter("l")
        ])
        
        let zRow = makeRow([
            .shift, .letter("z"), .letter("x"), .letter("c"),
            .letter("v"), .letter("b"), .letter("n"), .letter("m"),
            .backspace
        ])
        
        let bottomRow = makeRow([
            .number, .globe, .space(languageCode: languageCode), .return
        ])
        
        return [numberRow, qRow, aRow, zRow, bottomRow]
    }
    
    private func buildNumberRows() -> [UIView] {
        let numRow = makeRow([
            .letter("1"), .letter("2"), .letter("3"), .letter("4"),
            .letter("5"), .letter("6"), .letter("7"), .letter("8"),
            .letter("9"), .letter("0")
        ])
        
        let symRow = makeRow([
            .punctuation("-"), .punctuation("/"), .punctuation(":"),
            .punctuation(";"), .punctuation("("), .punctuation(")"),
            .punctuation("$"), .punctuation("&"), .punctuation("@"),
            .punctuation("\"")
        ])
        
        let puncRow = makeRow([
            .punctuation("."), .punctuation(","), .punctuation("?"),
            .punctuation("!"), .punctuation("'"),
            .backspace
        ])
        
        let bottomRow = makeRow([
            .symbol, .globe, .space(languageCode: languageCode), .return
        ])
        
        return [numRow, symRow, puncRow, bottomRow]
    }
    
    private func buildSymbolRows() -> [UIView] {
        let symRow1 = makeRow([
            .punctuation("["), .punctuation("]"), .punctuation("{"),
            .punctuation("}"), .punctuation("#"), .punctuation("%"),
            .punctuation("^"), .punctuation("*"), .punctuation("+"),
            .punctuation("=")
        ])
        
        let symRow2 = makeRow([
            .punctuation("_"), .punctuation("\\"), .punctuation("|"),
            .punctuation("~"), .punctuation("<"), .punctuation(">"),
            .punctuation("€"), .punctuation("£"), .punctuation("¥"),
            .punctuation("•")
        ])
        
        let symRow3 = makeRow([
            .punctuation("."), .punctuation(","), .punctuation("?"),
            .punctuation("!"), .punctuation("'"),
            .backspace
        ])
        
        let bottomRow = makeRow([
            .numberPad, .globe, .space(languageCode: languageCode), .return
        ])
        
        return [symRow1, symRow2, symRow3, bottomRow]
    }
    
    // MARK: - Updates
    
    private func updateSpaceKey() {
        // Space key updates with language code
        rebuildKeys()
    }
    
    private func updateShiftState() {
        shiftKey?.isShifted = isShifted
        // Update all letter keys to show shifted state
        for row in stackView.arrangedSubviews {
            guard let stack = row as? UIStackView else { continue }
            for case let key as KeyboardKeyView in stack.arrangedSubviews {
                if case .letter = key.keyType {
                    key.isShifted = isShifted
                }
            }
        }
    }
    
    // MARK: - Theme
    
    func applyTheme(traitCollection: UITraitCollection) {
        for row in stackView.arrangedSubviews {
            guard let stack = row as? UIStackView else { continue }
            for case let key as KeyboardKeyView in stack.arrangedSubviews {
                key.applyTheme(traitCollection: traitCollection)
            }
        }
    }
}