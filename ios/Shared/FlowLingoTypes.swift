import Foundation

// MARK: - Language Model

/// Represents a supported language with display metadata
struct Language: Codable, Equatable {
    let code: String       // e.g., "en", "es", "ja"
    let name: String       // e.g., "English", "Spanish", "Japanese"
    let nativeName: String // e.g., "English", "Español", "日本語"
    let isRTL: Bool        // Right-to-left support (Arabic, Hebrew, etc.)
    
    static let english = Language(code: "en", name: "English", nativeName: "English", isRTL: false)
    static let spanish = Language(code: "es", name: "Spanish", nativeName: "Español", isRTL: false)
    static let french = Language(code: "fr", name: "French", nativeName: "Français", isRTL: false)
    static let german = Language(code: "de", name: "German", nativeName: "Deutsch", isRTL: false)
    static let japanese = Language(code: "ja", name: "Japanese", nativeName: "日本語", isRTL: false)
    static let korean = Language(code: "ko", name: "Korean", nativeName: "한국어", isRTL: false)
    static let chineseSimplified = Language(code: "zh-CN", name: "Chinese (Simplified)", nativeName: "简体中文", isRTL: false)
    static let chineseTraditional = Language(code: "zh-TW", name: "Chinese (Traditional)", nativeName: "繁體中文", isRTL: false)
    static let arabic = Language(code: "ar", name: "Arabic", nativeName: "العربية", isRTL: true)
    static let hebrew = Language(code: "he", name: "Hebrew", nativeName: "עברית", isRTL: true)
    static let hindi = Language(code: "hi", name: "Hindi", nativeName: "हिन्दी", isRTL: false)
    static let portuguese = Language(code: "pt", name: "Portuguese", nativeName: "Português", isRTL: false)
    static let russian = Language(code: "ru", name: "Russian", nativeName: "Русский", isRTL: false)
    static let italian = Language(code: "it", name: "Italian", nativeName: "Italiano", isRTL: false)
    static let dutch = Language(code: "nl", name: "Dutch", nativeName: "Nederlands", isRTL: false)
    static let turkish = Language(code: "tr", name: "Turkish", nativeName: "Türkçe", isRTL: false)
    static let vietnamese = Language(code: "vi", name: "Vietnamese", nativeName: "Tiếng Việt", isRTL: false)
    static let thai = Language(code: "th", name: "Thai", nativeName: "ไทย", isRTL: false)
    static let indonesian = Language(code: "id", name: "Indonesian", nativeName: "Bahasa Indonesia", isRTL: false)
    
    static let supportedLanguages: [Language] = [
        .english, .spanish, .french, .german, .japanese, .korean,
        .chineseSimplified, .chineseTraditional, .arabic, .hebrew,
        .hindi, .portuguese, .russian, .italian, .dutch, .turkish,
        .vietnamese, .thai, .indonesian
    ]
    
    static func from(code: String) -> Language? {
        supportedLanguages.first { $0.code == code }
    }
}

// MARK: - Tone Options

/// Available tone modes for translation
enum Tone: String, CaseIterable, Codable {
    case formal
    case casual
    case friendly
    case urgent
    
    var displayName: String {
        switch self {
        case .formal: return "Formal"
        case .casual: return "Casual"
        case .friendly: return "Friendly"
        case .urgent: return "Urgent"
        }
    }
    
    var iconName: String {
        switch self {
        case .formal: return "briefcase.fill"
        case .casual: return "person.fill"
        case .friendly: return "heart.fill"
        case .urgent: return "exclamationmark.triangle.fill"
        }
    }
    
    var systemSymbol: String {
        switch self {
        case .formal: return "briefcase"
        case .casual: return "person"
        case .friendly: return "heart"
        case .urgent: return "exclamationmark.triangle"
        }
    }
}

// MARK: - Translation Request/Response

struct TranslationRequest: Codable {
    let text: String
    let sourceLang: String
    let targetLang: String
    let tone: Tone
    let context: String?
}

struct TranslationResponse: Codable {
    let translatedText: String
    let actionId: String
    let creditsRemaining: Int
}

// MARK: - Analysis Request/Response

struct AnalysisRequest: Codable {
    let text: String
    let language: String
}

struct AnalysisResponse: Codable {
    let analysis: String
    let suggestedReplies: [String]
}

// MARK: - AI Suggestion

struct AISuggestion: Codable, Equatable {
    let text: String
    let confidence: Double // 0.0 to 1.0
}

// MARK: - Subscription

enum SubscriptionTier: String, Codable {
    case free
    case premium
    case premiumAnnual
    case family
    case student
    case enterprise
    
    var displayName: String {
        switch self {
        case .free: return "Free"
        case .premium: return "Premium Monthly"
        case .premiumAnnual: return "Premium Annual"
        case .family: return "Family Plan"
        case .student: return "Student Plan"
        case .enterprise: return "Enterprise"
        }
    }
}

struct UserSubscription: Codable {
    let tier: SubscriptionTier
    let expiresAt: Date?
    let creditsRemaining: Int
    let isActive: Bool
}

// MARK: - User Preferences

struct UserPreferences: Codable {
    var nativeLanguage: String
    var targetLanguage: String
    var defaultTone: Tone
    var hapticsEnabled: Bool
    var clipboardDetectionEnabled: Bool
    var offlineModeEnabled: Bool
    var theme: ThemeMode
    
    static let `default` = UserPreferences(
        nativeLanguage: "en",
        targetLanguage: "es",
        defaultTone: .casual,
        hapticsEnabled: true,
        clipboardDetectionEnabled: false,
        offlineModeEnabled: false,
        theme: .system
    )
}

enum ThemeMode: String, Codable {
    case light
    case dark
    case system
}

// MARK: - Keyboard State

struct KeyboardState {
    var sourceLanguage: Language
    var targetLanguage: Language
    var currentTone: Tone
    var isAnalyzing: Bool
    var isOffline: Bool
    var suggestionChips: [AISuggestion]
    var detectedSourceLang: String?
    var clipboardText: String?
    var showBanner: Bool
    var isProcessing: Bool
    var errorMessage: String?
    
    static let initial = KeyboardState(
        sourceLanguage: .english,
        targetLanguage: .spanish,
        currentTone: .casual,
        isAnalyzing: false,
        isOffline: false,
        suggestionChips: [],
        detectedSourceLang: nil,
        clipboardText: nil,
        showBanner: false,
        isProcessing: false,
        errorMessage: nil
    )
}