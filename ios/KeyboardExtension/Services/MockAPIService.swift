import Foundation
import UIKit

// MARK: - Mock API Service

/// Provides mock AI responses for development and testing.
/// Replace with real APIClient calls when the backend is ready.
///
/// Mimics realistic latency (200-600ms), returns culturally-aware mock data
/// that varies per language pair. All responses are ephemeral — no data
/// is sent to any server.
final class MockAPIService {
    
    static let shared = MockAPIService()
    
    private init() {}
    
    // MARK: - Mock Translate
    
    /// Returns a mock translation response with realistic delay
    func translate(
        text: String,
        sourceLang: String,
        targetLang: String,
        tone: Tone,
        context: String? = nil
    ) async throws -> TranslationResponse {
        // Simulate network latency
        try await Task.sleep(nanoseconds: UInt64(Double.random(in: 0.2...0.6) * 1_000_000_000))
        
        let translated = mockTranslate(text, from: sourceLang, to: targetLang, tone: tone)
        
        return TranslationResponse(
            translatedText: translated,
            actionId: UUID().uuidString,
            creditsRemaining: max(0, 50 - Int.random(in: 0...5))
        )
    }
    
    // MARK: - Mock Analyze
    
    /// Returns a mock analysis response with realistic delay
    func analyze(
        text: String,
        language: String
    ) async throws -> AnalysisResponse {
        // Simulate network latency
        try await Task.sleep(nanoseconds: UInt64(Double.random(in: 0.3...0.7) * 1_000_000_000))
        
        return AnalysisResponse(
            analysis: mockAnalysis(for: text, language: language),
            suggestedReplies: mockReplies(for: language)
        )
    }
    
    // MARK: - Mock User Profile
    
    func fetchUserProfile() async throws -> UserProfileResponse {
        try await Task.sleep(nanoseconds: 200_000_000)
        
        return UserProfileResponse(
            id: "mock-user-001",
            email: "user@example.com",
            preferences: UserPreferencesResponse(
                nativeLang: "en",
                defaultTone: "casual"
            ),
            subscription: SubscriptionResponse(
                tier: "premium",
                expiresAt: ISO8601DateFormatter().string(from: Date().addingTimeInterval(365 * 86400))
            )
        )
    }
    
    // MARK: - Mock Translation Logic
    
    private func mockTranslate(_ text: String, from sourceLang: String, to targetLang: String, tone: Tone) -> String {
        // Simple mock translations for common phrases
        let greetings: [String: [String: String]] = [
            "en-es": ["Hello": "Hola", "How are you?": "¿Cómo estás?", "Thanks": "Gracias",
                      "Good morning": "Buenos días", "Goodbye": "Adiós", "Please": "Por favor",
                      "Yes": "Sí", "No": "No"],
            "en-fr": ["Hello": "Bonjour", "How are you?": "Comment allez-vous ?", "Thanks": "Merci",
                      "Good morning": "Bon matin", "Goodbye": "Au revoir", "Please": "S'il vous plaît",
                      "Yes": "Oui", "No": "Non"],
            "en-de": ["Hello": "Hallo", "How are you?": "Wie geht es Ihnen?", "Thanks": "Danke",
                      "Good morning": "Guten Morgen", "Goodbye": "Auf Wiedersehen", "Please": "Bitte",
                      "Yes": "Ja", "No": "Nein"],
            "en-ja": ["Hello": "こんにちは", "How are you?": "お元気ですか？", "Thanks": "ありがとうございます",
                      "Good morning": "おはようございます", "Goodbye": "さようなら", "Please": "お願いします",
                      "Yes": "はい", "No": "いいえ"],
        ]
        
        let key = "\(sourceLang)-\(targetLang)"
        
        // Check dictionary for direct match
        if let dictionary = greetings[key] {
            for (english, translated) in dictionary {
                if text.localizedCaseInsensitiveContains(english) {
                    // Adjust for tone
                    switch tone {
                    case .formal:
                        if targetLang == "es" { return translated.replacingOccurrences(of: "estás", with: "está usted") }
                        if targetLang == "ja" { return translated }
                        return translated
                    case .friendly:
                        if targetLang == "es" { return translated + " 😊" }
                        return translated
                    case .urgent:
                        return translated.uppercased() + "!"
                    case .casual:
                        return translated
                    }
                }
            }
        }
        
        // Fallback: simulated translation pattern
        return "[\(targetLang.uppercased())] \(text)"
    }
    
    // MARK: - Mock Analysis Logic
    
    private func mockAnalysis(for text: String, language: String) -> String {
        let analyses = [
            "This appears to be a casual conversation starter. The tone is friendly and informal.",
            "This message uses common everyday vocabulary. No significant cultural nuances detected.",
            "The language here is neutral and professional. Suitable for most business contexts.",
            "This contains mild informal expressions. In formal settings, consider using more structured phrasing.",
            "The message conveys a positive sentiment. The cultural context is universally understood.",
        ]
        return analyses.randomElement() ?? analyses[0]
    }
    
    private func mockReplies(for language: String) -> [String] {
        switch language {
        case "es":
            return ["¡Entendido!", "Gracias por compartir", "Claro, con gusto"]
        case "fr":
            return ["Compris!", "Merci d'avoir partagé", "Avec plaisir"]
        case "ja":
            return ["わかりました", "ありがとうございます", "承知しました"]
        case "de":
            return ["Verstanden!", "Danke fürs Teilen", "Gerne"]
        case "ko":
            return ["알겠습니다", "감사합니다", "좋습니다"]
        case "zh-CN":
            return ["明白了", "谢谢分享", "没问题"]
        case "ar":
            return ["فهمت!", "شكرا للمشاركة", "بكل سرور"]
        default:
            return ["Got it!", "Thanks for sharing", "Sure thing"]
        }
    }
    
    // MARK: - Mock Suggestions for Keyboard
    
    /// Generates mock AI suggestions based on target language
    func generateSuggestions(for targetLang: String) -> [AISuggestion] {
        let replies = mockReplies(for: targetLang)
        return replies.map { AISuggestion(text: $0, confidence: Double.random(in: 0.75...0.95)) }
    }
}

// MARK: - Mock Helper Extension

extension MockAPIService {
    /// Detect language using NSLinguisticTagger (works offline)
    static func detectLanguage(text: String) -> String {
        let tagger = NSLinguisticTagger(tagSchemes: [.language], options: 0)
        tagger.string = text
        let range = NSRange(location: 0, length: min(text.utf16.count, 100))
        let detectedLang = tagger.tag(at: 0, scheme: .language, tokenRange: nil, sentenceRange: nil)
        return detectedLang?.rawValue ?? "en"
    }
}