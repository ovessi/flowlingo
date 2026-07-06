package api

import (
    "net/http"
    "strings"
    "sync"
    "time"
)

type rateLimiter struct {
    mu       sync.Mutex
    attempts map[string][]time.Time
    limit    int
    window   time.Duration
}

func newRateLimiter(limit int, window time.Duration) *rateLimiter {
    return &rateLimiter{
        attempts: make(map[string][]time.Time),
        limit:    limit,
        window:   window,
    }
}

func (rl *rateLimiter) allow(key string) bool {
    rl.mu.Lock()
    defer rl.mu.Unlock()

    now := time.Now()
    cutoff := now.Add(-rl.window)

    // Clean old entries
    times := rl.attempts[key]
    var active []time.Time
    for _, t := range times {
        if t.After(cutoff) {
            active = append(active, t)
        }
    }

    if len(active) >= rl.limit {
        rl.attempts[key] = active
        return false
    }

    active = append(active, now)
    rl.attempts[key] = active
    return true
}

// AuthRateLimitMiddleware limits auth endpoints by IP address.
// 10 requests per minute per IP for login/register.
var authRateLimiter = newRateLimiter(10, 1*time.Minute)

func AuthRateLimitMiddleware(next http.HandlerFunc) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        ip := r.RemoteAddr
        // Strip port if present
        if idx := strings.LastIndex(ip, ":"); idx != -1 {
            ip = ip[:idx]
        }
        // Also check X-Forwarded-For header for proxied requests
        if fwd := r.Header.Get("X-Forwarded-For"); fwd != "" {
            ip = strings.Split(fwd, ",")[0]
        }

        if !authRateLimiter.allow(ip) {
            w.Header().Set("Retry-After", "60")
            http.Error(w, "too many requests: rate limit exceeded", http.StatusTooManyRequests)
            return
        }
        next(w, r)
    }
}