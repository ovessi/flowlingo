# Database Schema Specification - FlowLingo

## 1. Overview
The database is designed to handle user accounts, subscription state, AI action logging (for billing and analytics), and user personalization (Memory).

## 2. Table Definitions

### 2.1 `users`
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | UUID | PK, Default gen_random_uuid() | Unique User ID |
| `email` | VARCHAR(255) | Unique, Not Null | User email |
| `password_hash` | TEXT | Not Null | Hashed password |
| `created_at` | TIMESTAMP | Default NOW() | Account creation time |
| `updated_at` | TIMESTAMP | Default NOW() | Last profile update |
| `native_language`| VARCHAR(10) | Default 'en' | ISO 639-1 code |
| `default_tone` | VARCHAR(20) | Default 'casual' | User's preferred tone |

### 2.2 `subscriptions`
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | UUID | PK | Unique Subscription ID |
| `user_id` | UUID | FK -> users.id | Reference to user |
| `plan_type` | ENUM | 'free', 'premium', 'enterprise' | Tier level |
| `status` | VARCHAR(50) | 'active', 'canceled', 'past_due' | Stripe/AppStore status |
| `current_period_end` | TIMESTAMP | | Expiration date |
| `stripe_customer_id` | VARCHAR(255) | | Link to billing provider |

### 2.3 `ai_actions` (High volume)
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | UUID | PK | Action ID |
| `user_id` | UUID | FK -> users.id, Indexed | Who performed the action |
| `action_type` | VARCHAR(50) | 'translate', 'suggest', 'analyze' | Type of AI task |
| `provider` | VARCHAR(50) | 'openai', 'anthropic', etc. | AI model used |
| `tokens_used` | INTEGER | | Cost tracking |
| `latency_ms` | INTEGER | | Performance monitoring |
| `created_at` | TIMESTAMP | Default NOW(), Indexed | When it happened |

### 2.4 `user_memory` (Vector-supported)
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | UUID | PK | Memory fragment ID |
| `user_id` | UUID | FK -> users.id, Indexed | Owner |
| `content` | TEXT | Not Null | The actual text snippet/fact |
| `embedding` | VECTOR(1536) | | Vector representation (pgvector) |
| `created_at` | TIMESTAMP | | |

### 2.5 `feature_flags`
| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `key` | VARCHAR(100) | PK | e.g. 'enable_gpt4o' |
| `is_enabled` | BOOLEAN | Default FALSE | Global toggle |
| `rollout_pct` | INTEGER | Default 0 | Percentage of users |

## 3. Indexing Strategy
*   `IDX_ai_actions_user_created`: Composite index on `user_id` and `created_at` for rapid usage history lookups.
*   `IDX_user_memory_vector`: HNSW or IVFFlat index on `embedding` for fast semantic search.
*   `IDX_subscriptions_status`: For identifying users needing renewal notifications.

## 4. Migration Strategy
*   Use `golang-migrate` or `Prisma` for versioned migrations.
*   Strict "No breaking changes" policy for table alters (expand-and-contract pattern).
