# FlowLingo Backend

The backend engine for FlowLingo, providing AI-powered translation, cultural analysis, and subscription management.

## Stack
- **Language:** Go 1.25+
- **Database:** PostgreSQL (Neon) with `sqlx` and `pq`
- **Cache:** Redis (Upstash)
- **AI Orchestration:** Multi-provider failover (OpenAI, Anthropic, Gemini)
- **Authentication:** JWT-based with social login support

## Quick Start (Local Development)

### Prerequisites
- Go 1.25 or higher
- Docker and Docker Compose
- A Postgres database (or use the one in Docker Compose)

### 1. Configure Environment
Copy the example environment file and fill in your keys:
```bash
cp .env.example .env
```

### 2. Start Infrastructure
Start the database and Redis using Docker Compose:
```bash
docker compose up -d db redis
```

### 3. Run Migrations
Apply the database schema:
```bash
go run cmd/migrate/main.go
```

### 4. Run the Server
```bash
go run cmd/api/main.go
```
The API will be available at `http://localhost:8080`.

## Production Deployment

### Railway
1. Connect your GitHub repository to Railway.
2. Railway will automatically detect the `railway.json` and `Dockerfile`.
3. Add the required environment variables in the Railway dashboard.

### Render
1. Create a new "Web Service" on Render.
2. Connect your repository.
3. Select "Docker" as the runtime.
4. Render will use `render.yaml` for configuration.

### Fly.io
1. Install the Fly CLI and run `fly launch`.
2. Fly.io will use `fly.toml` and the `Dockerfile`.

## Environment Variables
Refer to `.env.example` for a full list of required and optional variables. Key variables include:
- `DATABASE_URL`: Your Postgres connection string.
- `JWT_SECRET`: Secret key for signing authentication tokens.
- `OPENAI_API_KEY`: Primary AI provider key.
- `CORS_ORIGINS`: Comma-separated list of allowed frontend origins.

## API Endpoints

### Authentication
- `POST /v1/auth/register` - Email registration
- `POST /v1/auth/login` - Email login
- `POST /v1/auth/social` - Social login (Google/Apple)

### AI Actions
- `POST /v1/ai/translate` - Natural language translation with tone control
- `POST /v1/ai/analyze` - Cultural context and reply suggestions

### User
- `GET /v1/user/profile` - Get user details and preferences
- `PATCH /v1/user/settings` - Update language and tone preferences
- `GET /v1/user/memory` - View AI-learned preferences

### System
- `GET /v1/health` - Health check and system status

## Architecture
- **Multi-LLM Failover:** The AI service automatically tries OpenAI, then Anthropic, then Gemini to ensure high availability.
- **PII Scrubbing:** All user text is scrubbed for personally identifiable information before being sent to third-party AI providers.
- **Tiered Rate Limiting:** Free users are limited to 5 AI actions per day, while premium users have unlimited access.
- **Vector Memory:** User preferences are stored and retrieved using vector embeddings to personalize AI responses.

## Verification
To verify a deployment, call the health endpoint:
```bash
curl https://your-backend-api.com/v1/health
```
Expected response:
```json
{
  "status": "ok",
  "version": "1.0.0",
  "database": "connected",
  "ai_providers": {
    "openai": "configured",
    "anthropic": "configured",
    "gemini": "configured"
  }
}
```
