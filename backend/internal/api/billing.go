package api

import (
	"encoding/json"
	"io"
	"net/http"

	"github.com/flowlingo/backend/internal/billing"
	"github.com/google/uuid"
)

func (h *Handler) CreateCheckout(w http.ResponseWriter, r *http.Request) {
	userID, ok := r.Context().Value(userIDKey).(uuid.UUID)
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	var input struct {
		PlanID     string `json:"plan_id"`
		SuccessURL string `json:"success_url"`
		CancelURL  string `json:"cancel_url"`
	}
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		http.Error(w, "invalid request", http.StatusBadRequest)
		return
	}

	checkoutURL, err := h.billingService.CreateCheckoutSession(r.Context(), billing.CheckoutRequest{
		UserID:     userID,
		PlanID:     input.PlanID,
		SuccessURL: input.SuccessURL,
		CancelURL:  input.CancelURL,
	})
	if err != nil {
		http.Error(w, "billing error: "+err.Error(), http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(map[string]string{
		"checkout_url": checkoutURL,
	})
}

func (h *Handler) StripeWebhook(w http.ResponseWriter, r *http.Request) {
	const MaxBodyBytes = int64(65536)
	r.Body = http.MaxBytesReader(w, r.Body, MaxBodyBytes)
	payload, err := io.ReadAll(r.Body)
	if err != nil {
		http.Error(w, "too large", http.StatusBadRequest)
		return
	}

	sigHeader := r.Header.Get("Stripe-Signature")
	err = h.billingService.HandleWebhook(r.Context(), payload, sigHeader)
	if err != nil {
		http.Error(w, "webhook error: "+err.Error(), http.StatusBadRequest)
		return
	}

	w.WriteHeader(http.StatusOK)
}

func (h *Handler) GetPricing(w http.ResponseWriter, r *http.Request) {
	plans := []map[string]interface{}{
		{
			"id": "free",
			"name": "Free",
			"price": 0,
			"features": []string{"5 AI actions/day", "Basic translation"},
		},
		{
			"id": "premium_monthly",
			"name": "Premium Monthly",
			"price": 9.99,
			"features": []string{"Unlimited AI actions", "Tone profiles", "AI Memory"},
		},
	}
	json.NewEncoder(w).Encode(plans)
}

func (h *Handler) ValidateMobileReceipt(w http.ResponseWriter, r *http.Request) {
	userID, ok := r.Context().Value(userIDKey).(uuid.UUID)
	if !ok {
		http.Error(w, "unauthorized", http.StatusUnauthorized)
		return
	}

	var input struct {
		Platform string `json:"platform"`
		Receipt  string `json:"receipt"`
	}
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		http.Error(w, "invalid request", http.StatusBadRequest)
		return
	}

	var err error
	if input.Platform == "apple" {
		err = h.billingService.ValidateAppleReceipt(r.Context(), userID, input.Receipt)
	} else if input.Platform == "google" {
		err = h.billingService.ValidateGoogleReceipt(r.Context(), userID, input.Receipt)
	} else {
		http.Error(w, "unsupported platform", http.StatusBadRequest)
		return
	}

	if err != nil {
		http.Error(w, "validation error: "+err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
}
