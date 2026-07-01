import UIKit

// MARK: - API Client

/// Network client for FlowLingo backend services.
/// All requests go through JWT-authenticated HTTPS endpoints.
/// The keyboard extension only sends data when the user explicitly triggers an action.
final class APIClient {
    
    static let shared = APIClient()
    
    // MARK: - Configuration
    
    private let baseURL = "https://api.flowlingo.ai/v1"
    private let session: URLSession
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    // MARK: - Auth
    
    private var jwtToken: String? {
        get { KeychainHelper.shared.load(key: "auth_token") }
        set {
            if let token = newValue {
                KeychainHelper.shared.save(key: "auth_token", value: token)
            } else {
                KeychainHelper.shared.delete(key: "auth_token")
            }
        }
    }
    
    // MARK: - Initialization
    
    private init() {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 30
        config.waitsForConnectivity = true
        config.allowsCellularAccess = true
        
        // Certificate pinning would be added here in production
        session = URLSession(configuration: config)
    }
    
    // MARK: - API Methods
    
    /// Translate text with tone and context awareness
    func translate(
        text: String,
        sourceLang: String,
        targetLang: String,
        tone: Tone,
        context: String? = nil
    ) async throws -> TranslationResponse {
        let request = TranslationRequest(
            text: text,
            sourceLang: sourceLang,
            targetLang: targetLang,
            tone: tone,
            context: context
        )
        
        return try await performRequest(
            endpoint: "/ai/translate",
            body: request
        )
    }
    
    /// Analyze copied message for cultural context, slang, and suggested replies
    func analyze(
        text: String,
        language: String
    ) async throws -> AnalysisResponse {
        let request = AnalysisRequest(text: text, language: language)
        return try await performRequest(endpoint: "/ai/analyze", body: request)
    }
    
    /// Fetch user profile and preferences
    func fetchUserProfile() async throws -> UserProfileResponse {
        return try await performRequest(endpoint: "/user/profile", method: "GET")
    }
    
    // MARK: - Core Request Logic
    
    private func performRequest<T: Codable>(
        endpoint: String,
        method: String = "POST",
        body: some Codable
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add auth token if available
        if let token = jwtToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Encode body
        let bodyData = try encoder.encode(body)
        request.httpBody = bodyData
        
        // Perform request
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return try decoder.decode(T.self, from: data)
        case 401:
            throw APIError.unauthorized
        case 402:
            throw APIError.paymentRequired
        case 429:
            throw APIError.rateLimited
        case 503:
            throw APIError.aiUnavailable
        default:
            throw APIError.serverError(httpResponse.statusCode)
        }
    }
    
    private func performRequest<T: Codable>(
        endpoint: String,
        method: String = "GET"
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let token = jwtToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return try decoder.decode(T.self, from: data)
        case 401:
            throw APIError.unauthorized
        default:
            throw APIError.serverError(httpResponse.statusCode)
        }
    }
}

// MARK: - API Errors

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case paymentRequired
    case rateLimited
    case aiUnavailable
    case serverError(Int)
    case networkError(Error)
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid request URL"
        case .invalidResponse:
            return "Invalid server response"
        case .unauthorized:
            return "Please sign in to continue"
        case .paymentRequired:
            return "Free limit reached. Upgrade to continue."
        case .rateLimited:
            return "Too many requests. Please wait a moment."
        case .aiUnavailable:
            return "AI service temporarily unavailable. Try again."
        case .serverError(let code):
            return "Server error (\(code)). Please try again."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError:
            return "Failed to process server response"
        }
    }
}

// MARK: - Response Types

struct UserProfileResponse: Codable {
    let id: String
    let email: String?
    let preferences: UserPreferencesResponse
    let subscription: SubscriptionResponse
}

struct UserPreferencesResponse: Codable {
    let nativeLang: String
    let defaultTone: String
}

struct SubscriptionResponse: Codable {
    let tier: String
    let expiresAt: String?
}

// MARK: - Simple Keychain Helper

final class KeychainHelper {
    static let shared = KeychainHelper()
    
    private init() {}
    
    func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        
        // Delete existing item first
        delete(key: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Network Reachability Helper

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private init() {}
    
    /// Simple connectivity check — in production, use NWPathMonitor
    var isConnected: Bool {
        // Quick check by seeing if we can reach the API host
        // In production, this would use NWPathMonitor from Network.framework
        return true // Optimistic assumption; actual check happens at request time
    }
}