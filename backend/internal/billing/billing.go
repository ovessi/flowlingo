package billing

import (
	"context"
	"fmt"
	"time"

	"github.com/flowlingo/backend/internal/user"
	"github.com/google/uuid"
	"github.com/stripe/stripe-go/v81"
	"github.com/stripe/stripe-go/v81/checkout/session"
	"github.com/stripe/stripe-go/v81/webhook"
)

type Service struct {
	userRepo *user.Repository
	stripeKey string
	webhookSecret string
}

func NewService(userRepo *user.Repository, stripeKey, webhookSecret string) *Service {
	stripe.Key = stripeKey
	return &Service{
		userRepo: userRepo,
		stripeKey: stripeKey,
		webhookSecret: webhookSecret,
	}
}

type CheckoutRequest struct {
	UserID     uuid.UUID
	PlanID     string
	SuccessURL string
	CancelURL  string
}

func (s *Service) CreateCheckoutSession(ctx context.Context, req CheckoutRequest) (string, error) {
	u, err := s.userRepo.GetByID(ctx, req.UserID)
	if err != nil {
		return "", err
	}

	params := &stripe.CheckoutSessionParams{
		CustomerEmail: stripe.String(u.Email),
		PaymentMethodTypes: stripe.StringSlice([]string{
			"card",
		}),
		LineItems: []*stripe.CheckoutSessionLineItemParams{
			{
				Price:    stripe.String(req.PlanID),
				Quantity: stripe.Int64(1),
			},
		},
		Mode:       stripe.String(string(stripe.CheckoutSessionModeSubscription)),
		SuccessURL: stripe.String(req.SuccessURL),
		CancelURL:  stripe.String(req.CancelURL),
		Metadata: map[string]string{
			"user_id": req.UserID.String(),
		},
	}

	sess, err := session.New(params)
	if err != nil {
		return "", err
	}

	return sess.URL, nil
}

func (s *Service) HandleWebhook(ctx context.Context, payload []byte, sigHeader string) error {
	event, err := webhook.ConstructEvent(payload, sigHeader, s.webhookSecret)
	if err != nil {
		return fmt.Errorf("bad webhook signature: %w", err)
	}

	switch event.Type {
	case "checkout.session.completed":
		var sess stripe.CheckoutSession
		err := sess.UnmarshalJSON(event.Data.Raw)
		if err != nil {
			return err
		}
		return s.handleCheckoutCompleted(ctx, &sess)
	case "customer.subscription.updated", "customer.subscription.deleted":
		var sub stripe.Subscription
		err := sub.UnmarshalJSON(event.Data.Raw)
		if err != nil {
			return err
		}
		return s.handleSubscriptionUpdated(ctx, &sub)
	}

	return nil
}

func (s *Service) handleCheckoutCompleted(ctx context.Context, sess *stripe.CheckoutSession) error {
	userIDStr := sess.Metadata["user_id"]
	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		return err
	}

	subID := ""
	if sess.Subscription != nil {
		subID = sess.Subscription.ID
	}
	
	sub := &user.Subscription{
		UserID:                 userID,
		PlanType:               "premium",
		Status:                 "active",
		CurrentPeriodEnd:       time.Now().AddDate(0, 1, 0),
		StripeCustomerID:       sess.Customer.ID,
		Platform:               "stripe",
		ExternalSubscriptionID: subID,
	}

	return s.userRepo.UpsertSubscription(ctx, sub)
}

func (s *Service) handleSubscriptionUpdated(ctx context.Context, stripeSub *stripe.Subscription) error {
	sub, err := s.userRepo.GetSubscriptionByExternalID(ctx, stripeSub.ID)
	if err != nil {
		return err
	}

	sub.Status = string(stripeSub.Status)
	sub.CurrentPeriodEnd = time.Unix(stripeSub.CurrentPeriodEnd, 0)
	
	return s.userRepo.UpsertSubscription(ctx, sub)
}

func (s *Service) ValidateAppleReceipt(ctx context.Context, userID uuid.UUID, receipt string) error {
	sub := &user.Subscription{
		UserID:           userID,
		PlanType:         "premium",
		Status:           "active",
		CurrentPeriodEnd: time.Now().AddDate(0, 1, 0),
		Platform:         "apple",
	}
	return s.userRepo.UpsertSubscription(ctx, sub)
}

func (s *Service) ValidateGoogleReceipt(ctx context.Context, userID uuid.UUID, receipt string) error {
	sub := &user.Subscription{
		UserID:           userID,
		PlanType:         "premium",
		Status:           "active",
		CurrentPeriodEnd: time.Now().AddDate(0, 1, 0),
		Platform:         "google",
	}
	return s.userRepo.UpsertSubscription(ctx, sub)
}

func (s *Service) IsPremium(ctx context.Context, userID uuid.UUID) (bool, error) {
	sub, err := s.userRepo.GetSubscription(ctx, userID)
	if err != nil {
		return false, nil
	}

	if sub.Status != "active" && sub.Status != "trialing" {
		if time.Now().Before(sub.CurrentPeriodEnd.AddDate(0, 0, 3)) {
			return true, nil
		}
		return false, nil
	}

	return sub.PlanType == "premium" || sub.PlanType == "enterprise", nil
}
