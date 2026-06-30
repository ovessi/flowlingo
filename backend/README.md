# FlowLingo Backend

Foundational API server for FlowLingo built with Go.

## Stack
- Go (1.25+)
- PostgreSQL (Neon)
- JWT Authentication
- bcrypt for password hashing

## Structure
- `cmd/api`: Main API server
- `cmd/migrate`: Simple migration runner
- `internal/api`: HTTP handlers and middleware
- `internal/auth`: JWT and Password logic
- `internal/db`: Database connection setup
- `internal/user`: User models and repository
- `migrations`: SQL migration files

## Environment Variables
- `DATABASE_URL`: Postgres DSN (e.g., Neon). Falls back to `local.db` (SQLite).
- `JWT_SECRET`: Secret for signing JWTs.
- `UPSTASH_REDIS_REST_URL`: Redis URL for caching.
- `OPENAI_API_KEY`: API key for OpenAI.
- `ANTHROPIC_API_KEY`: API key for Anthropic.
- `GOOGLE_API_KEY`: API key for Google Gemini.

## AI Features
- **Multi-LLM Abstraction**: Supports OpenAI (GPT-4o), Anthropic (Claude 3.5 Sonnet), and Gemini (1.5 Flash).
- **Failover**: Automatically retries with the next provider if one fails.
- **Caching**: Translation results are cached in Redis for 24 hours.
- **PII Scrubbing**: Automatically hides emails and phone numbers before sending data to AI providers.
- **Rate Limiting**: Enforces tier-based limits (Free: 5/day).


## API Endpoints
- `POST /v1/auth/register`: Register a new user
- `POST /v1/auth/login`: Login and get JWT
- `GET /v1/user/profile`: Get current user profile (Auth required)
- `PATCH /v1/user/settings`: Update user settings (Auth required)
