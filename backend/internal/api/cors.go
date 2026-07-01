package api

import (
	"net/http"
	"os"
	"strings"
)

// CORS wraps an http.Handler with CORS headers.
// It reads allowed origins from the CORS_ORIGINS env var.
// Falls back to localhost origins for development.
func CORSMiddleware(next http.Handler) http.Handler {
	originsEnv := os.Getenv("CORS_ORIGINS")
	var allowedOrigins []string
	if originsEnv != "" {
		for _, o := range strings.Split(originsEnv, ",") {
			allowedOrigins = append(allowedOrigins, strings.TrimSpace(o))
		}
	} else {
		allowedOrigins = []string{
			"http://localhost:3000",
			"http://localhost:8080",
			"https://flowlingo.ctonew.app",
		}
	}
	allowedOriginsMap := make(map[string]bool, len(allowedOrigins))
	for _, o := range allowedOrigins {
		allowedOriginsMap[o] = true
	}

	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		origin := r.Header.Get("Origin")

		// Allow the origin if it's in our list, or if it's an iOS/Android app URL scheme
		if allowedOriginsMap[origin] || origin == "" {
			w.Header().Set("Access-Control-Allow-Origin", origin)
		} else if len(allowedOrigins) == 1 {
			w.Header().Set("Access-Control-Allow-Origin", allowedOrigins[0])
		}

		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization, Stripe-Signature")
		w.Header().Set("Access-Control-Allow-Credentials", "true")
		w.Header().Set("Access-Control-Max-Age", "86400")

		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}

		next.ServeHTTP(w, r)
	})
}