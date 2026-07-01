# Privacy & Security Architecture - FlowLingo

## 1. Keyboard Security Principles
Mobile keyboards are highly sensitive. FlowLingo follows a "Privacy by Design" approach to earn user trust and pass app store reviews.

### 1.1 Data Minimization
*   **No Passive Logging:** The keyboard *never* records or transmits keystrokes unless the user explicitly triggers an AI action (Translate, Analyze, Suggest).
*   **Ephemeral Context:** Text sent for analysis is deleted from production logs after 24 hours unless the user has opted-in to "Personal Memory."
*   **Local Processing:** Basic spelling and localization checks are performed on-device to minimize cloud round-trips.

### 1.2 "Full Access" Compliance
*   **iOS/Android Sandbox:** We respect the OS sandbox. "Full Access" is used strictly for network connectivity and clipboard access, not for background surveillance.
*   **Transparent UI:** A prominent indicator appears whenever data is being transmitted to the cloud.

## 2. Technical Safeguards

### 2.1 Encryption
*   **In-Transit:** TLS 1.3 with Certificate Pinning in the mobile app.
*   **At-Rest:** AES-256 encryption for all database records. User Memory embeddings are stored with anonymized IDs.

### 2.2 PII Redaction
*   **The "Scrubber" Service:** Before text is sent to LLM providers (OpenAI, Anthropic), an automated service masks potential PII (emails, phone numbers, credit cards) with tokens (e.g., `[EMAIL_REDACTED]`). These are restored locally after translation.

### 2.3 User Memory Controls
*   **Opt-in Only:** AI Memory is disabled by default.
*   **Granular Deletion:** Users can view and delete individual "Memory" snippets or wipe their entire history from the dashboard.
*   **Zero-Knowledge (Target Architecture):** Exploration of client-side encryption for memory where only the user holds the key (Post-Phase 1).

## 3. Compliance Roadmap
*   **GDPR:** Support for "Right to be Forgotten" and Data Portability (JSON export).
*   **CCPA:** Strict "Do Not Sell My Info" adherence.
*   **Apple/Google Policies:** Bi-weekly audit of keyboard extension code to ensure no unintended data leaks.

## 4. Incident Response
*   **Auto-Kill Switch:** If a security anomaly is detected, the AI Orchestrator can revoke all keyboard session tokens globally.
*   **Bug Bounty:** Establish a program for security researchers to report vulnerabilities in the keyboard sandbox.
