import UIKit
import Social

// MARK: - Share View Controller

/// Allows users to share text from Safari, Notes, or other apps into FlowLingo for analysis.
/// Displays a compact analysis card with translation, cultural context, and suggested replies.
final class ShareViewController: SLComposeServiceViewController {
    
    // MARK: - Configuration
    
    private let mockService = MockAPIService.shared
    
    private lazy var analysisGroup: SLComposeSheetConfigurationItem = {
        let item = SLComposeSheetConfigurationItem()!
        item.title = "Analysis Type"
        item.value = "Translate"
        item.tapHandler = { [weak self] in
            self?.showAnalysisTypePicker()
        }
        return item
    }()
    
    private lazy var toneGroup: SLComposeSheetConfigurationItem = {
        let item = SLComposeSheetConfigurationItem()!
        item.title = "Tone"
        item.value = Tone.casual.displayName
        item.tapHandler = { [weak self] in
            self?.showTonePicker()
        }
        return item
    }()
    
    private var analysisType = "Translate"
    private var selectedTone = Tone.casual
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure appearance
        view.tintColor = UIColor(red: 0.310, green: 0.275, blue: 0.898, alpha: 1.0) // Indigo
        
        // Set placeholder
        placeholder = "Enter text or paste from clipboard..."
    }
    
    override func isContentValid() -> Bool {
        // Require at least some text
        return !(contentText?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
    }
    
    override func configurationItems() -> [Any]! {
        return [analysisGroup, toneGroup]
    }
    
    // MARK: - Action
    
    override func didSelectPost() {
        guard let text = contentText, !text.isEmpty else {
            return
        }
        
        // Show progress
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        // Perform analysis via MockAPIService (replace with APIClient when backend is ready)
        Task { @MainActor in
            do {
                let response = try await mockService.analyze(
                    text: text,
                    language: "auto"
                )
                
                showResult(
                    text: text,
                    analysis: response.analysis,
                    replies: response.suggestedReplies
                )
            } catch {
                showError(error.localizedDescription)
            }
            
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
    
    // MARK: - Results Display
    
    private func showResult(text: String, analysis: String, replies: [String]) {
        let resultVC = AnalysisResultViewController(
            originalText: text,
            analysis: analysis,
            replies: replies
        )
        
        navigationController?.pushViewController(resultVC, animated: true)
        
        // Change the right button to "Done"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissShare)
        )
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Analysis Failed",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func dismissShare() {
        extensionContext?.completeRequest(returningItems: nil)
    }
    
    // MARK: - Pickers
    
    private func showAnalysisTypePicker() {
        let alert = UIAlertController(title: "Analysis Type", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Translate", style: .default) { [weak self] _ in
            self?.analysisType = "Translate"
            self?.analysisGroup.value = "Translate"
            self?.reloadConfigurationItems()
        })
        
        alert.addAction(UIAlertAction(title: "Explain Slang", style: .default) { [weak self] _ in
            self?.analysisType = "Explain Slang"
            self?.analysisGroup.value = "Slang"
            self?.reloadConfigurationItems()
        })
        
        alert.addAction(UIAlertAction(title: "Cultural Context", style: .default) { [weak self] _ in
            self?.analysisType = "Cultural Context"
            self?.analysisGroup.value = "Culture"
            self?.reloadConfigurationItems()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // iPad support
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
        }
        
        present(alert, animated: true)
    }
    
    private func showTonePicker() {
        let alert = UIAlertController(title: "Select Tone", message: nil, preferredStyle: .actionSheet)
        
        for tone in Tone.allCases {
            alert.addAction(UIAlertAction(title: tone.displayName, style: .default) { [weak self] _ in
                self?.selectedTone = tone
                self?.toneGroup.value = tone.displayName
                self?.reloadConfigurationItems()
            })
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
        }
        
        present(alert, animated: true)
    }
}

// MARK: - Analysis Result View Controller

final class AnalysisResultViewController: UIViewController {
    
    private let originalText: String
    private let analysis: String
    private let replies: [String]
    
    init(originalText: String, analysis: String, replies: [String]) {
        self.originalText = originalText
        self.analysis = analysis
        self.replies = replies
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
        title = "Analysis"
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        // Original text
        let originalSection = createSection(title: "Original", content: originalText)
        
        // Analysis
        let analysisSection = createSection(title: "Analysis", content: analysis)
        
        // Suggested replies
        let repliesSection = createRepliesSection()
        
        stackView.addArrangedSubview(originalSection)
        stackView.addArrangedSubview(analysisSection)
        stackView.addArrangedSubview(repliesSection)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
        ])
    }
    
    private func createSection(title: String, content: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .secondarySystemGroupedBackground
        container.layer.cornerRadius = 12
        container.clipsToBounds = true
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        
        let contentLabel = UILabel()
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.text = content
        contentLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        contentLabel.numberOfLines = 0
        
        container.addSubview(titleLabel)
        container.addSubview(contentLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            contentLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            contentLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            contentLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
        ])
        
        return container
    }
    
    private func createRepliesSection() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .secondarySystemGroupedBackground
        container.layer.cornerRadius = 12
        container.clipsToBounds = true
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Suggested Replies"
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .secondaryLabel
        
        container.addSubview(titleLabel)
        
        var lastView: UIView = titleLabel
        
        for reply in replies {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(reply, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            button.backgroundColor = UIColor.systemIndigo.withAlphaComponent(0.1)
            button.layer.cornerRadius = 10
            button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
            button.addTarget(self, action: #selector(copyToClipboard(_:)), for: .touchUpInside)
            
            container.addSubview(button)
            
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 8),
                button.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
                button.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            ])
            
            lastView = button
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            lastView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
        ])
        
        return container
    }
    
    @objc private func copyToClipboard(_ sender: UIButton) {
        guard let text = sender.title(for: .normal) else { return }
        UIPasteboard.general.string = text
        HapticFeedbackService.shared.aiActionComplete()
    }
}