# API Specification - FlowLingo

## 1. Authentication
All requests must include a Bearer token in the Authorization header.
`Authorization: Bearer <JWT>`

## 2. Endpoints

### 2.1 AI Operations

#### POST `/v1/ai/translate`
Translates text with tone and context awareness.
*   **Request Body:**
    ```json
    {
      "text": "Hello, how are you?",
      "source_lang": "en",
      "target_lang": "es",
      "tone": "formal",
      "context": "Professional email introduction"
    }
    ```
*   **Response (200 OK):**
    ```json
    {
      "translated_text": "Hola, ¿cómo se encuentra usted?",
      "action_id": "uuid-123",
      "credits_remaining": 45
    }
    ```

#### POST `/v1/ai/analyze`
Analyzes a copied message for cultural context and slang.
*   **Request Body:**
    ```json
    {
      "text": "That's cap, fr fr.",
      "language": "en"
    }
    ```
*   **Response (200 OK):**
    ```json
    {
      "analysis": "This is Gen-Z slang. 'Cap' means lying. 'fr fr' means 'for real, for real' (emphasis on truth).",
      "suggested_replies": [
        "No way!",
        "I'm serious.",
        "Why would I lie?"
      ]
    }
    ```

### 2.2 User Profile & Settings

#### GET `/v1/user/profile`
Retrieve user preferences and subscription status.
*   **Response (200 OK):**
    ```json
    {
      "id": "uuid",
      "email": "user@example.com",
      "preferences": {
        "native_lang": "en",
        "default_tone": "casual"
      },
      "subscription": {
        "tier": "premium",
        "expires_at": "2026-12-31T23:59:59Z"
      }
    }
    ```

#### PATCH `/v1/user/settings`
Update preferences.
*   **Request Body:**
    ```json
    {
      "default_tone": "friendly"
    }
    ```

### 2.3 Subscription & Billing

#### POST `/v1/billing/create-checkout`
Generates a Stripe/AppStore checkout session.
*   **Request Body:**
    ```json
    {
      "plan_id": "premium_monthly",
      "success_url": "https://flowlingo.ai/success",
      "cancel_url": "https://flowlingo.ai/cancel"
    }
    ```

## 3. Error Codes
| Code | Name | Description |
| :--- | :--- | :--- |
| 400 | `invalid_request` | Missing or malformed parameters. |
| 401 | `unauthorized` | Missing or expired JWT. |
| 402 | `payment_required` | User has reached free tier limit. |
| 429 | `too_many_requests` | Rate limit exceeded. |
| 503 | `ai_unavailable` | Downstream AI provider error (trigger failover). |
