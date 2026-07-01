# System Architecture - FlowLingo

## 1. High-Level Diagram Overview
FlowLingo uses a distributed microservices architecture designed for low-latency AI interactions and global scale.

### Components:
1.  **Client Tier:** iOS Keyboard Extension, Android Keyboard Service, Mobile App (React Native/Flutter).
2.  **Edge Tier:** Cloudflare Workers / AWS CloudFront for global caching and request routing.
3.  **API Gateway:** Load balancer and authentication layer (Next.js API routes or Go/FastAPI).
4.  **Application Tier:** Microservices for AI Orchestration, User Management, and Billing.
5.  **AI Orchestration Layer:**
    *   **Provider Abstraction:** A unified interface for OpenAI, Anthropic, and Google Vertex AI.
    *   **Prompt Engine:** Dynamic context-aware prompt generation.
    *   **Caching Layer:** Redis cache for common phrases and frequent translation pairs.
6.  **Data Tier:**
    *   **Primary DB:** PostgreSQL (managed, e.g., Supabase or Neon) for user data and metadata.
    *   **Vector DB:** Pinecone or pgvector for storing user "Memory" and context snippets.
    *   **Analytics:** ClickHouse or Snowflake for high-volume event tracking.

## 2. Request Flow: AI Translation/Suggestion
1.  **User Trigger:** User taps "Translate" or "Analyze" on the keyboard.
2.  **Request:** Keyboard sends payload (Text, Source/Target Lang, Tone, Context) to API Gateway via HTTPS.
3.  **Auth:** API Gateway validates JWT and checks subscription status (Rate Limiting).
4.  **Context Enrichment:** Orchestrator pulls relevant User Memory from Vector DB.
5.  **AI Call:** Orchestrator selects optimal LLM based on latency/cost/language and sends the prompt.
6.  **Response Handling:** AI result is post-processed (localization checks) and cached in Redis.
7.  **Return:** Final text/suggestion returned to keyboard.

## 3. Scale & Availability
*   **Multi-Region Deployment:** API servers in US-East, EU-West, and Asia-Pacific.
*   **Auto-scaling:** K8s or Serverless (AWS Lambda/Vercel) to handle peak messaging hours.
*   **Circuit Breaker:** If one AI provider is down, automatically failover to the next best provider.

## 4. Latency Optimization
*   **Streaming Responses:** For longer analysis/replies to show progress.
*   **Pre-fetching:** Predictively fetch suggestions when a user copies text to the clipboard.
*   **Edge Functions:** Localization and basic tone shifts handled at the edge to save round-trip time.

## 5. Security & Compliance
*   **End-to-End Encryption:** TLS 1.3 for all transit.
*   **Data Minimization:** No storage of full conversation history on servers unless explicitly opted-in for "Memory" features.
*   **PII Masking:** Scrubbing sensitive data before sending to 3rd-party AI providers.
