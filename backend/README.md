# FlowLingo Backend

Foundational API server for FlowLingo built with Go.

## Stack
- Go (1.23+)
- PostgreSQL (Neon in Production, SQLite fallback for Local)
- JWT Authentication
- Multi-LLM Orchestration (OpenAI, Anthropic, Gemini)
- Redis Caching
- Dockerized for Deployment

## Structure
- `cmd/api`: Main API server
- `cmd/migrate`: Simple migration runner
- `internal/api`: HTTP handlers, middleware (CORS, Auth)
- `internal/auth`: JWT and Password logic
- `internal/db`: Database connection setup
- `internal/user`: User models and repository
- `migrations`: SQL migration files

## Development

### Setup
1. Copy `.env.example` to `.env` and fill in your keys.
2. Run with Docker Compose:
   ```bash
   docker-compose up --build
   ```
   OR locally:
   ```bash
   go run ./cmd/api/main.go
   ```

### Database Migrations
To apply migrations locally:
```bash
go run ./cmd/migrate/main.go
```

## Production Deployment

### 1. Docker
The repository includes a `Dockerfile` for containerized environments.
```bash
docker build -t flowlingo-backend .
docker run -p 8080:8080 --env-file .env flowlingo-backend
```

### 2. Platform Specifics
- **Railway**: Uses the provided `railway.json`. Connect your GitHub repo, and it will automatically detect the Dockerfile.
- **Render/Fly.io**: Point to the `Dockerfile` and ensure `PORT` environment variable is set.

### 3. Production Database & Migrations
When deploying to production (e.g., Neon Postgres):
1. Set the `DATABASE_URL` environment variable.
2. Run the migration tool as a one-off job or entrypoint task:
   ```bash
   go run ./cmd/migrate/main.go
   ```

## Environment Variables
- `PORT`: Port to listen on (default 8080).
- `DATABASE_URL`: Postgres DSN.
- `JWT_SECRET`: Secret for signing JWTs.
- `UPSTASH_REDIS_REST_URL`: Redis connection string.
- `OPENAI_API_KEY`: API key for OpenAI.
- `ANTHROPIC_API_KEY`: API key for Anthropic.
- `GOOGLE_API_KEY`: API key for Google Gemini.
- `STRIPE_API_KEY`: API key for Stripe.
- `STRIPE_WEBHOOK_SECRET`: Secret for Stripe webhooks.

## AI Features
- **Multi-LLM Abstraction**: Supports OpenAI, Anthropic, and Gemini.
- **Failover**: Automatically retries with the next provider if one fails.
- **Caching**: Results cached for 24h.
- **PII Scrubbing**: Masks sensitive data before AI processing.
- **Rate Limiting**: Enforces usage tiers.

## API Endpoints
- `GET /health`: Health check
- `POST /v1/auth/register`: Register a new user
- `POST /v1/auth/login`: Login and get JWT
- `POST /v1/ai/translate`: Translate text (Auth required)
- `POST /v1/ai/analyze`: Cultural context & suggestions (Auth required)
- `GET /v1/user/profile`: Get profile (Auth required)
- `PATCH /v1/user/settings`: Update settings (Auth required)
- `GET /v1/billing/pricing`: Get available plans
- `POST /v1/billing/create-checkout`: Create Stripe session (Auth required)
