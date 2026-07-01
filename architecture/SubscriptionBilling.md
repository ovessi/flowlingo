# Subscription & Billing Architecture - FlowLingo

## 1. Monetization Tiers

| Tier | Price (est.) | Features |
| :--- | :--- | :--- |
| **Free** | $0 | 5 AI actions/day, Basic translation, Standard tone. |
| **Premium** | $9.99/mo | Unlimited AI actions, Tone profiles, AI Memory, Offline packs. |
| **Family** | $19.99/mo | Up to 5 users, Shared memory pools. |
| **Enterprise** | Custom | Team management, Admin controls, Dedicated AI endpoints. |

## 2. Integration Architecture

### 2.1 Multi-Platform Billing
FlowLingo must synchronize state across three payment gateways:
1.  **Apple IAP:** Primary for iOS users.
2.  **Google Play Billing:** Primary for Android users.
3.  **Stripe:** Primary for Web/Enterprise and secondary for mobile web.

### 2.2 RevenueCat / Unified Entitlement Layer
To simplify cross-platform entitlements, we will use a service like **RevenueCat** or a custom internal **Entitlement Service**.
*   **Source of Truth:** The database `subscriptions` table.
*   **Webhook Handling:** Servers listen for `sub.renewed`, `sub.cancelled`, and `sub.expired` events from all providers.

## 3. The Entitlement Flow
1.  **Check:** Keyboard app sends User ID to `/v1/user/profile` on boot.
2.  **Validation:** API checks DB for active subscription and current action count (if free).
3.  **Gatekeeper:** If `actions_remaining <= 0` AND `tier == 'free'`, return `402 Payment Required`.
4.  **Upsell:** Keyboard UI displays a "Daily Limit Reached" chip with an "Upgrade" button.

## 4. Edge Cases & Grace Periods
*   **Grace Period:** Users get 3 days of "Premium" access after a failed payment before reverting to "Free."
*   **Offline Mode:** If the user is offline, the app uses the last known cached entitlement state (valid for 24 hours).
*   **Refund Handling:** Automatic revocation of access upon Stripe/Apple refund event.

## 5. Security
*   **Receipt Validation:** Server-side validation of all App Store / Google Play receipts to prevent "Jailbreak" bypasses.
*   **Idempotency:** Stripe/IAP requests must include an idempotency key to prevent double-charging on poor mobile connections.
