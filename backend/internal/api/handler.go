package api

import (
    "context"
    "encoding/json"
    "net/http"
    "strings"
    "time"

    "github.com/flowlingo/backend/internal/ai"
    "github.com/flowlingo/backend/internal/auth"
    "github.com/flowlingo/backend/internal/billing"
    "github.com/flowlingo/backend/internal/user"
    "github.com/google/uuid"
)

type contextKey string

const userIDKey contextKey = "user_id"

type Handler struct {
    userRepo       *user.Repository
    tokenService   *auth.TokenService
    aiService      *ai.Service
    billingService *billing.Service
}

func NewHandler(userRepo *user.Repository, tokenService *auth.TokenService, aiService *ai.Service, billingService *billing.Service) *Handler {
    return &Handler{
        userRepo:       userRepo,
        tokenService:   tokenService,
        aiService:      aiService,
        billingService: billingService,
    }
}

func (h *Handler) Translate(w http.ResponseWriter, r *http.Request) {
    userID, ok := r.Context().Value(userIDKey).(uuid.UUID)
    if !ok {
        http.Error(w, "unauthorized", http.StatusUnauthorized)
        return
    }

    // 1. Rate Limiting
    premium, err := h.billingService.IsPremium(r.Context(), userID)
    plan := "free"
    if err == nil && premium {
        plan = "premium"
    }

    if plan == "free" {
        count, err := h.userRepo.GetActionCount(r.Context(), userID, time.Now().Add(-24*time.Hour))
        if err == nil && count >= 5 {
            http.Error(w, "payment_required: free tier limit reached", http.StatusPaymentRequired)
            return
        }
    }

    var req ai.TranslationRequest
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        http.Error(w, "invalid request", http.StatusBadRequest)
        return
    }

    // 2. Personalization via Memory
    if plan != "free" { // Memory is a premium feature
        embedding, err := h.aiService.Embed(r.Context(), req.Text)
        if err == nil {
            memories, err := h.userRepo.SearchMemory(r.Context(), userID, embedding, 3)
            if err == nil && len(memories) > 0 {
                var sb strings.Builder
                sb.WriteString(req.Context)
                sb.WriteString("\n\nUser Preferences from Memory:\n")
                for _, m := range memories {
                    sb.WriteString("- ")
                    sb.WriteString(m.Content)
                    sb.WriteString("\n")
                }
                req.Context = sb.String()
            }
        }
    }

    resp, err := h.aiService.Translate(r.Context(), req)
    if err != nil {
        http.Error(w, "ai error: "+err.Error(), http.StatusServiceUnavailable)
        return
    }

    // 3. Log Action
    actionID := uuid.New()
    _ = h.userRepo.LogAction(r.Context(), actionID, userID, "translate", resp.Provider, resp.TokensUsed, resp.LatencyMs)

    // 4. Prepare Response
    creditsRemaining := 0
    if plan == "free" {
        count, _ := h.userRepo.GetActionCount(r.Context(), userID, time.Now().Add(-24*time.Hour))
        creditsRemaining = 5 - count
    } else {
        creditsRemaining = 9999 // Unlimited
    }


    json.NewEncoder(w).Encode(map[string]interface{}{
        "translated_text":   resp.TranslatedText,
        "action_id":         actionID,
        "credits_remaining": creditsRemaining,
    })
}

func (h *Handler) Analyze(w http.ResponseWriter, r *http.Request) {
    userID, ok := r.Context().Value(userIDKey).(uuid.UUID)
    if !ok {
        http.Error(w, "unauthorized", http.StatusUnauthorized)
        return
    }

    // 1. Rate Limiting
    premium, err := h.billingService.IsPremium(r.Context(), userID)
    plan := "free"
    if err == nil && premium {
        plan = "premium"
    }

    if plan == "free" {
        count, err := h.userRepo.GetActionCount(r.Context(), userID, time.Now().Add(-24*time.Hour))
        if err == nil && count >= 5 {
            http.Error(w, "payment_required: free tier limit reached", http.StatusPaymentRequired)
            return
        }
    }

    var req ai.AnalysisRequest
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        http.Error(w, "invalid request", http.StatusBadRequest)
        return
    }

    resp, err := h.aiService.Analyze(r.Context(), req)
    if err != nil {
        http.Error(w, "ai error: "+err.Error(), http.StatusServiceUnavailable)
        return
    }

    // 2. Log Action
    actionID := uuid.New()
    _ = h.userRepo.LogAction(r.Context(), actionID, userID, "analyze", resp.Provider, resp.TokensUsed, resp.LatencyMs)

    // 3. Prepare Response
    creditsRemaining := 0
    if plan == "free" {
        count, _ := h.userRepo.GetActionCount(r.Context(), userID, time.Now().Add(-24*time.Hour))
        creditsRemaining = 5 - count
    } else {
        creditsRemaining = 9999
    }

    json.NewEncoder(w).Encode(map[string]interface{}{
        "analysis":          resp.Analysis,
        "suggested_replies": resp.SuggestedReplies,
        "action_id":         actionID,
        "credits_remaining": creditsRemaining,
    })
}

func (h *Handler) GetMemories(w http.ResponseWriter, r *http.Request) {
    userID, ok := r.Context().Value(userIDKey).(uuid.UUID)
    if !ok {
        http.Error(w, "unauthorized", http.StatusUnauthorized)
        return
    }

    memories, err := h.userRepo.GetMemories(r.Context(), userID)
    if err != nil {
        http.Error(w, "error fetching memories", http.StatusInternalServerError)
        return
    }

    json.NewEncoder(w).Encode(memories)
}

func (h *Handler) AddMemory(w http.ResponseWriter, r *http.Request) {
    userID, ok := r.Context().Value(userIDKey).(uuid.UUID)
    if !ok {
        http.Error(w, "unauthorized", http.StatusUnauthorized)
        return
    }

    var req struct {
        Content string `json:"content"`
    }
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        http.Error(w, "invalid request", http.StatusBadRequest)
        return
    }

    embedding, err := h.aiService.Embed(r.Context(), req.Content)
    if err != nil {
        http.Error(w, "error generating embedding", http.StatusInternalServerError)
        return
    }

    id, err := h.userRepo.AddMemory(r.Context(), userID, req.Content, embedding)
    if err != nil {
        http.Error(w, "error saving memory", http.StatusInternalServerError)
        return
    }

    json.NewEncoder(w).Encode(map[string]interface{}{
        "id": id,
    })
}

func (h *Handler) DeleteMemory(w http.ResponseWriter, r *http.Request) {
    userID, ok := r.Context().Value(userIDKey).(uuid.UUID)
    if !ok {
        http.Error(w, "unauthorized", http.StatusUnauthorized)
        return
    }

    idStr := r.PathValue("id")
    id, err := uuid.Parse(idStr)
    if err != nil {
        http.Error(w, "invalid id", http.StatusBadRequest)
        return
    }

    if err := h.userRepo.DeleteMemory(r.Context(), userID, id); err != nil {
        http.Error(w, "error deleting memory", http.StatusInternalServerError)
        return
    }

    w.WriteHeader(http.StatusNoContent)
}

func (h *Handler) Register(w http.ResponseWriter, r *http.Request) {
    var input struct {
        Email    string `json:"email"`
        Password string `json:"password"`
    }

    if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
        http.Error(w, "invalid input", http.StatusBadRequest)
        return
    }

    hashedPassword, err := auth.HashPassword(input.Password)
    if err != nil {
        http.Error(w, "error hashing password", http.StatusInternalServerError)
        return
    }

    u := &user.User{
        Email:        input.Email,
        PasswordHash: &hashedPassword,
    }

    if err := h.userRepo.Create(r.Context(), u); err != nil {
        http.Error(w, "error creating user: "+err.Error(), http.StatusInternalServerError)
        return
    }

    w.WriteHeader(http.StatusCreated)
    json.NewEncoder(w).Encode(u)
}

func (h *Handler) Login(w http.ResponseWriter, r *http.Request) {
    var input struct {
        Email    string `json:"email"`
        Password string `json:"password"`
    }

    if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
        http.Error(w, "invalid input", http.StatusBadRequest)
        return
    }

    u, err := h.userRepo.GetByEmail(r.Context(), input.Email)
    if err != nil {
        http.Error(w, "invalid credentials", http.StatusUnauthorized)
        return
    }

    if u.PasswordHash == nil || !auth.CheckPasswordHash(input.Password, *u.PasswordHash) {
        http.Error(w, "invalid credentials", http.StatusUnauthorized)
        return
    }

    token, err := h.tokenService.GenerateToken(u.ID)
    if err != nil {
        http.Error(w, "error generating token", http.StatusInternalServerError)
        return
    }

    json.NewEncoder(w).Encode(map[string]string{"token": token})
}

func (h *Handler) GetProfile(w http.ResponseWriter, r *http.Request) {
    userID, ok := r.Context().Value(userIDKey).(uuid.UUID)
    if !ok {
        http.Error(w, "unauthorized", http.StatusUnauthorized)
        return
    }

    u, err := h.userRepo.GetByID(r.Context(), userID)
    if err != nil {
        http.Error(w, "user not found", http.StatusNotFound)
        return
    }

    sub, _ := h.userRepo.GetSubscription(r.Context(), userID)
    tier := "free"
    var expiresAt *time.Time
    if sub != nil {
        tier = sub.PlanType
        expiresAt = &sub.CurrentPeriodEnd
    }

    json.NewEncoder(w).Encode(map[string]interface{}{
        "id":    u.ID,
        "email": u.Email,
        "preferences": map[string]string{
            "native_lang":  u.NativeLanguage,
            "default_tone": u.DefaultTone,
        },
        "subscription": map[string]interface{}{
            "tier":       tier,
            "expires_at": expiresAt,
        },
    })
}

func (h *Handler) UpdateSettings(w http.ResponseWriter, r *http.Request) {
    userID, ok := r.Context().Value(userIDKey).(uuid.UUID)
    if !ok {
        http.Error(w, "unauthorized", http.StatusUnauthorized)
        return
    }

    var input struct {
        NativeLanguage string `json:"native_language"`
        DefaultTone    string `json:"default_tone"`
    }

    if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
        http.Error(w, "invalid input", http.StatusBadRequest)
        return
    }

    u, err := h.userRepo.GetByID(r.Context(), userID)
    if err != nil {
        http.Error(w, "user not found", http.StatusNotFound)
        return
    }

    if input.NativeLanguage != "" {
        u.NativeLanguage = input.NativeLanguage
    }
    if input.DefaultTone != "" {
        u.DefaultTone = input.DefaultTone
    }

    if err := h.userRepo.Update(r.Context(), u); err != nil {
        http.Error(w, "error updating user", http.StatusInternalServerError)
        return
    }

    h.GetProfile(w, r)
}

func (h *Handler) Health(w http.ResponseWriter, r *http.Request) {
    dbStatus := "connected"
    if err := h.userRepo.Ping(r.Context()); err != nil {
        dbStatus = "disconnected"
    }

    aiStatus := map[string]string{}
    if h.aiService != nil {
        aiStatus = h.aiService.GetProvidersStatus()
    }

    json.NewEncoder(w).Encode(map[string]interface{}{
        "status":       "ok",
        "timestamp":    time.Now().UTC().Format(time.RFC3339),
        "version":      "1.0.0",
        "database":     dbStatus,
        "ai_providers": aiStatus,
    })
}

func (h *Handler) AuthMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        authHeader := r.Header.Get("Authorization")
        if authHeader == "" {
            http.Error(w, "authorization header missing", http.StatusUnauthorized)
            return
        }

        parts := strings.Split(authHeader, " ")
        if len(parts) != 2 || parts[0] != "Bearer" {
            http.Error(w, "invalid authorization header", http.StatusUnauthorized)
            return
        }

        claims, err := h.tokenService.ValidateToken(parts[1])
        if err != nil {
            http.Error(w, "invalid token", http.StatusUnauthorized)
            return
        }

        ctx := context.WithValue(r.Context(), userIDKey, claims.UserID)
        next.ServeHTTP(w, r.WithContext(ctx))
    })
}
