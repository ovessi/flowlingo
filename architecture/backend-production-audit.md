# Backend Production Readiness Audit

**Date:** 2026-07-04  
**Repository:** ovessi/flowlingo (commit 7684a85)  
**Go Version Target:** 1.23 (CI)  

---

## 1. AI Translation Pipeline — Status: STUBBED

### What works
- Three real provider integrations: OpenAI (GPT-4o), Anthropic (Claude 3.5 Sonnet), Gemini (1.5 Flash)
- Multi-provider failover — iterates providers until one succeeds
- PII scrubber (email + phone regex replacement)
- Redis cache layer for translations (24h TTL)
- Embedding generation for user memory (OpenAI Ada-002, Gemini text-embedding-004)

### What's missing
- **Fallback to MockProvider** — all real providers silently skip if API key is empty, MockProvider returns fake data. No "API key not configured" warning to caller.
- **Streaming responses** — no support for streaming translations/analysis to the keyboard client
- **Cost tracking** — no per-user token budget or spending limits
- **Embedding-only providers** — Anthropic returns error for Embed(), which is fine but could degrade UX
- **Prompt injection protection** — no input sanitization beyond PII scrubbing

### Credentials required
| Variable | Source | Notes |
|---|---|---|
| `OPENAI_API_KEY` | OpenAI | Primary — handles translate, analyze, embeddings |
| `ANTHROPIC_API_KEY` | Anthropic | Fallback — translate + analyze only |
| `GOOGLE_API_KEY` | Google AI | Secondary fallback — translate + analyze + embeddings |
| `UPSTASH_REDIS_REST_URL` | Upstash | Optional cache — 24h TTL on translations |

---

## 2. Database — Status: STUBBED (SQLite fallback)

### What works
- Dual-driver support: PostgreSQL (production) and SQLite (dev/fallback)
- 5 migration files covering all tables
- Proper Postgres connection pooling: 25 max open/idle, 5min lifetime
- pgvector `<=>` operator for similarity search with graceful SQLite fallback
- Unique constraint on subscriptions.user_id for single entitlement

### What's missing
- **No Neon/non-local database provisioned** — currently uses `local.db` SQLite file
- **No connection retry** — NewDB() fails fast on ping error, no retry logic
- **No read replicas** — single connection pool, no read/write splitting
- **No migration tooling in Docker CMD** — Dockerfile only runs `./server`, migrations must be run separately via `./migrate`
- **Postgres-specific SQL in user.Update()** — uses `NOW()` which works in Postgres but not SQLite for RETURNING clauses
- **No connection encryption enforcement** — `sslmode=require` is documented but not enforced in code

### Credentials required
| Variable | Source | Notes |
|---|---|---|
| `DATABASE_URL` | Neon | Postgres connection string e.g. `postgresql://user:pass@ep-xxx.us-east-2.aws.neon.tech/flowlingo?sslmode=require` |

---

## 3. Authentication & Sessions — Status: STUBBED (needs hardening)

### What works
- JWT-based auth with HS256 signing
- Email/password registration and login with bcrypt password hashing
- Token validation middleware on protected routes
- 24-hour token expiry

### What's missing
- **CRITICAL: JWT secret defaults to `"default-secret-for-development"`** — must be changed to a strong random secret before production
- **No OAuth integration** — google_id and apple_id columns in schema, but no actual Apple Sign In / Google Sign In SDK integration
- **No token refresh mechanism** — tokens expire in 24h with no refresh endpoint
- **No rate limiting on auth endpoints** — /v1/auth/login and /v1/auth/register have no rate limiting (brute force vector)
- **No email verification**
- **No password reset flow**
- **Session stored only in JWT** — no server-side session revocation capability
- **No MFA/2FA support**

### Credentials required
| Variable | Source | Notes |
|---|---|---|
| `JWT_SECRET` | Generate locally | `openssl rand -base64 32`, never the default |

---

## 4. Rate Limiting — Status: STUBBED (basic)

### What works
- Database-based action counter: 5 AI actions/day for free users
- Premium users get "unlimited" (shown as 9999)

### What's missing
- **No IP-based rate limiting** — auth endpoints and health endpoint are unthrottled
- **No in-memory rate limiter** — every check hits the database (count query per request)
- **No distributed rate limiting** — no Redis-based counter for multi-instance deployments
- **No per-endpoint limits** — all AI actions share the same bucket
- **Rate limit headers** — no `X-RateLimit-Remaining`, `X-RateLimit-Reset` headers in responses

---

## 5. Deployment — Status: CONFIGURED (not live)

### What works
- Multi-stage Dockerfile (Go 1.23 → Alpine 3.20) with health check
- docker-compose.yml for local Postgres development
- Deployment configs for 3 platforms: Fly.io (fly.toml), Render (render.yaml), Railway (railway.json)
- GitHub Actions CI: Go build + vet on push/PR to main
- Health endpoint at GET /v1/health

### What's missing
- **No actual deployment** — no service is running on any cloud provider
- **Docker build removed from CI** — current backend-ci.yml only has build-and-test job, no Docker build job
- **No CD pipeline** — CI only, no automated deploy to any platform
- **No staging environment** — no pre-production deploy step
- **No blue/green or canary deployment strategy**
- **Docker HEALTHCHECK uses wget** — works but `--spider` flag may not exist on all Alpine versions

---

## 6. Secrets Management — Status: NOT IMPLEMENTED

### What works
- `.env.example` documents all required env vars
- Render has `generateValue: true` for JWT_SECRET

### What's missing
- **JWT secret default `"default-secret-for-development"` in main.go** — critical security issue
- **No secrets manager** (HashiCorp Vault, AWS Secrets Manager, Doppler, etc.)
- **No secret rotation strategy**
- **Secrets passed via env vars** — OK for MVP, but should integrate a secrets manager before launch

---

## 7. Observability — Status: MISSING

### What works
- Basic `log.Printf` for startup messages and provider errors
- Health endpoint: `GET /v1/health` returns status, db connectivity, AI provider configuration

### What's missing
- **No structured logging** — uses Go stdlib `log` package, no JSON-logging or log levels
- **No metrics service** — no Prometheus endpoints, no Datadog/Grafana/OpenTelemetry
- **No distributed tracing** — no request tracing across services
- **No error tracking** — no Sentry, Rollbar, or similar
- **No request logging middleware** — no access logs for API calls
- **No synthetic monitoring / uptime checks** — beyond the Docker/Fly.io health check
- **No alerting** — no PagerDuty/Opsgenie/Slack integration for service degradation

---

## 8. Health Checks — Status: BASIC

### What works
- `GET /v1/health` — returns JSON with db_status, ai_provider statuses, version, timestamp
- Docker HEALTHCHECK configured (wget to /v1/health)
- Fly.io and Render health check paths set to /v1/health

### What's missing
- **No separate readiness probe** — liveness and readiness share the same endpoint
- **No dependency-specific checks** — no Redis check, no AI provider health check timeout
- **No /v1/ready endpoint** for Kubernetes-style readiness
- **No synthetic external monitoring**

---

## 9. Minor Issues Found

1. **Duplicate CORS middleware** — `cors.go` and `middleware.go` both define CORS handlers; `middleware.go` allows `*` (insecure); `cors.go` is the one used in main.go
2. **POST /v1/auth/register returns hashed password** — `json:"-"` is set on PasswordHash, but the user object is returned directly from Create() without stripping fields
3. **Now() in user.Update()** — uses `NOW()` which is Postgres-specific; SQLite uses `datetime('now')`
4. **No `go.sum` checks in CI** — CI does `go mod download` but doesn't run `go mod verify`
5. **GitHub token in CI** — `GITHUB_TOKEN` not set for Docker push (but Docker build isn't in CI)
6. **Apple/Google IAP validation is stubbed** — `ValidateAppleReceipt` and `ValidateGoogleReceipt` create a premium subscription without verifying the receipt

---

## Summary: Implementation Priority Tasks

### P0 — Security (blocking launch)
1. Generate strong `JWT_SECRET` and remove dev default
2. Provision Neon Postgres database and set `DATABASE_URL`
3. Obtain and configure at least one AI API key (`OPENAI_API_KEY`)
4. Add rate limiting to auth endpoints (login/register)
5. Add `go mod verify` to CI workflow

### P1 — Deployment
6. Deploy to one cloud provider (Fly.io recommended — config is most complete)
7. Re-add Docker build job to CI workflow
8. Add CD step to automatically deploy on main merge
9. Provision Redis (Upstash) and set `UPSTASH_REDIS_REST_URL`

### P2 — Observability
10. Add structured logging (uber-go/zap)
11. Add request logging middleware
12. Add Prometheus metrics endpoint
13. Add Sentry/error tracking

### P3 — Features
14. OAuth integration (Apple Sign In, Google Sign In)
15. Token refresh endpoint
16. Email verification flow
17. Subscription webhook verification (Stripe)
18. Real Apple/Google IAP receipt validation

### P4 — Polish
19. Fix Postgres-specific SQL in user.Update() for cross-compatibility
20. Add rate limit headers to API responses
21. Add migration run to startup script (docker-compose starts both)
22. Remove duplicate CORS middleware file
