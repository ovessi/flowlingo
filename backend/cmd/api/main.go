package main

import (
    "context"
    "log"
    "net/http"
    "os"
    "time"

    "github.com/flowlingo/backend/internal/api"
    "github.com/flowlingo/backend/internal/auth"
    "github.com/flowlingo/backend/internal/db"
    "github.com/flowlingo/backend/internal/user"
    "github.com/flowlingo/backend/internal/ai"
    "github.com/flowlingo/backend/internal/billing"
)

func main() {
    dsn := os.Getenv("DATABASE_URL")
    if dsn == "" {
        dsn = "local.db" // Fallback to local sqlite
    }

    secret := os.Getenv("JWT_SECRET")
    if secret == "" {
        secret = "default-secret-for-development"
    }

    database, err := db.NewDB(dsn)
    if err != nil {
        log.Fatal(err)
    }
    defer database.Close()

    userRepo := user.NewRepository(database.DB)
    tokenService := auth.NewTokenService(secret, 24*time.Hour)

    // AI Setup
    var providers []ai.Provider
    if key := os.Getenv("OPENAI_API_KEY"); key != "" {
        providers = append(providers, ai.NewOpenAIProvider(key, "gpt-4o"))
    }
    if key := os.Getenv("ANTHROPIC_API_KEY"); key != "" {
        providers = append(providers, ai.NewAnthropicProvider(key, "claude-3-5-sonnet-20240620"))
    }
    if key := os.Getenv("GOOGLE_API_KEY"); key != "" {
        if p, err := ai.NewGeminiProvider(context.Background(), key, "gemini-1.5-flash"); err == nil {
            providers = append(providers, p)
        }
    }
    providers = append(providers, &ai.MockProvider{}) // Fallback

    var cache ai.Cache
    if redisURL := os.Getenv("UPSTASH_REDIS_REST_URL"); redisURL != "" {
        // Note: Using standard redis protocol for now, if Upstash URL is set
        cache = ai.NewRedisCache(redisURL)
    }

    aiService := ai.NewService(cache, &ai.Scrubber{}, providers...)
    
    billingService := billing.NewService(userRepo, os.Getenv("STRIPE_API_KEY"), os.Getenv("STRIPE_WEBHOOK_SECRET"))
    
    handler := api.NewHandler(userRepo, tokenService, aiService, billingService)


    mux := http.NewServeMux()

    // Health check
    mux.HandleFunc("GET /health", func(w http.ResponseWriter, r *http.Request) {
        w.WriteHeader(http.StatusOK)
        w.Write([]byte("OK"))
    })

    mux.HandleFunc("POST /v1/auth/register", handler.Register)
    mux.HandleFunc("POST /v1/auth/login", handler.Login)

    // AI routes
    mux.Handle("POST /v1/ai/translate", handler.AuthMiddleware(http.HandlerFunc(handler.Translate)))
    mux.Handle("POST /v1/ai/analyze", handler.AuthMiddleware(http.HandlerFunc(handler.Analyze)))

    // Memory routes
    mux.Handle("GET /v1/user/memory", handler.AuthMiddleware(http.HandlerFunc(handler.GetMemories)))
    mux.Handle("POST /v1/user/memory", handler.AuthMiddleware(http.HandlerFunc(handler.AddMemory)))
    mux.Handle("DELETE /v1/user/memory/{id}", handler.AuthMiddleware(http.HandlerFunc(handler.DeleteMemory)))

    // Protected routes
    mux.Handle("GET /v1/user/profile", handler.AuthMiddleware(http.HandlerFunc(handler.GetProfile)))
    mux.Handle("PATCH /v1/user/settings", handler.AuthMiddleware(http.HandlerFunc(handler.UpdateSettings)))

    // Billing routes
    mux.Handle("POST /v1/billing/create-checkout", handler.AuthMiddleware(http.HandlerFunc(handler.CreateCheckout)))
    mux.Handle("POST /v1/billing/validate-receipt", handler.AuthMiddleware(http.HandlerFunc(handler.ValidateMobileReceipt)))
    mux.HandleFunc("POST /v1/billing/webhook", handler.StripeWebhook)
    mux.HandleFunc("GET /v1/billing/pricing", handler.GetPricing)


    port := os.Getenv("PORT")
    if port == "" {
        port = "8080"
    }

    srv := &http.Server{
        Addr:         ":" + port,
        Handler:      api.CorsMiddleware(mux),
        ReadTimeout:  10 * time.Second,
        WriteTimeout: 10 * time.Second,
        IdleTimeout:  120 * time.Second,
    }

    log.Printf("Server starting on port %s", port)
    if err := srv.ListenAndServe(); err != nil {
        log.Fatal(err)
    }
}
