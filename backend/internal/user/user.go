package user

import (
    "context"
    "time"

    "github.com/google/uuid"
    "github.com/jmoiron/sqlx"
)

type User struct {
    ID             uuid.UUID `db:"id" json:"id"`
    Email          string    `db:"email" json:"email"`
    PasswordHash   *string   `db:"password_hash" json:"-"`
    GoogleID       *string   `db:"google_id" json:"google_id,omitempty"`
    AppleID        *string   `db:"apple_id" json:"apple_id,omitempty"`
    NativeLanguage string    `db:"native_language" json:"native_language"`
    DefaultTone    string    `db:"default_tone" json:"default_tone"`
    CreatedAt      time.Time `db:"created_at" json:"created_at"`
    UpdatedAt      time.Time `db:"updated_at" json:"updated_at"`
}

type Subscription struct {
    ID                     uuid.UUID `db:"id" json:"id"`
    UserID                 uuid.UUID `db:"user_id" json:"user_id"`
    PlanType               string    `db:"plan_type" json:"plan_type"`
    Status                 string    `db:"status" json:"status"`
    CurrentPeriodEnd       time.Time `db:"current_period_end" json:"current_period_end"`
    StripeCustomerID       string    `db:"stripe_customer_id" json:"stripe_customer_id"`
    Platform               string    `db:"platform" json:"platform"`
    ExternalSubscriptionID string    `db:"external_subscription_id" json:"external_subscription_id"`
}

type Repository struct {
    db *sqlx.DB
}


func NewRepository(db *sqlx.DB) *Repository {
    return &Repository{db: db}
}

func (r *Repository) Create(ctx context.Context, u *User) error {
    query := `
        INSERT INTO users (email, password_hash, google_id, apple_id, native_language, default_tone)
        VALUES (:email, :password_hash, :google_id, :apple_id, :native_language, :default_tone)
        RETURNING id, created_at, updated_at
    `
    rows, err := r.db.NamedQueryContext(ctx, query, u)
    if err != nil {
        return err
    }
    defer rows.Close()

    if rows.Next() {
        if err := rows.Scan(&u.ID, &u.CreatedAt, &u.UpdatedAt); err != nil {
            return err
        }
    }

    return nil
}

func (r *Repository) GetByEmail(ctx context.Context, email string) (*User, error) {
    var u User
    query := `SELECT * FROM users WHERE email = $1`
    if err := r.db.GetContext(ctx, &u, query, email); err != nil {
        return nil, err
    }
    return &u, nil
}

func (r *Repository) GetByID(ctx context.Context, id uuid.UUID) (*User, error) {
    var u User
    query := `SELECT * FROM users WHERE id = $1`
    if err := r.db.GetContext(ctx, &u, query, id); err != nil {
        return nil, err
    }
    return &u, nil
}

func (r *Repository) GetByGoogleID(ctx context.Context, googleID string) (*User, error) {
    var u User
    query := `SELECT * FROM users WHERE google_id = $1`
    if err := r.db.GetContext(ctx, &u, query, googleID); err != nil {
        return nil, err
    }
    return &u, nil
}

func (r *Repository) GetByAppleID(ctx context.Context, appleID string) (*User, error) {
    var u User
    query := `SELECT * FROM users WHERE apple_id = $1`
    if err := r.db.GetContext(ctx, &u, query, appleID); err != nil {
        return nil, err
    }
    return &u, nil
}

func (r *Repository) Update(ctx context.Context, u *User) error {
    query := `
        UPDATE users
        SET native_language = :native_language, default_tone = :default_tone, updated_at = NOW()
        WHERE id = :id
        RETURNING updated_at
    `
    rows, err := r.db.NamedQueryContext(ctx, query, u)
    if err != nil {
        return err
    }
    defer rows.Close()

    if rows.Next() {
        if err := rows.Scan(&u.UpdatedAt); err != nil {
            return err
        }
    }

    return nil
}

func (r *Repository) GetSubscription(ctx context.Context, userID uuid.UUID) (*Subscription, error) {
    var s Subscription
    query := `SELECT * FROM subscriptions WHERE user_id = $1 ORDER BY updated_at DESC LIMIT 1`
    if err := r.db.GetContext(ctx, &s, query, userID); err != nil {
        return nil, err
    }
    return &s, nil
}

func (r *Repository) GetActionCount(ctx context.Context, userID uuid.UUID, since time.Time) (int, error) {
    var count int
    query := `SELECT COUNT(*) FROM ai_actions WHERE user_id = $1 AND created_at >= $2`
    if err := r.db.GetContext(ctx, &count, query, userID, since); err != nil {
        return 0, err
    }
    return count, nil
}

func (r *Repository) UpsertSubscription(ctx context.Context, s *Subscription) error {
    query := `
        INSERT INTO subscriptions (user_id, plan_type, status, current_period_end, stripe_customer_id, platform, external_subscription_id)
        VALUES (:user_id, :plan_type, :status, :current_period_end, :stripe_customer_id, :platform, :external_subscription_id)
        ON CONFLICT (user_id) DO UPDATE SET
            plan_type = EXCLUDED.plan_type,
            status = EXCLUDED.status,
            current_period_end = EXCLUDED.current_period_end,
            stripe_customer_id = EXCLUDED.stripe_customer_id,
            platform = EXCLUDED.platform,
            external_subscription_id = EXCLUDED.external_subscription_id,
            updated_at = NOW()
        RETURNING id
    `
    rows, err := r.db.NamedQueryContext(ctx, query, s)
    if err != nil {
        return err
    }
    defer rows.Close()
    if rows.Next() {
        return rows.Scan(&s.ID)
    }
    return nil
}

func (r *Repository) GetSubscriptionByExternalID(ctx context.Context, externalID string) (*Subscription, error) {
    var s Subscription
    query := `SELECT * FROM subscriptions WHERE external_subscription_id = $1 LIMIT 1`
    if err := r.db.GetContext(ctx, &s, query, externalID); err != nil {
        return nil, err
    }
    return &s, nil
}

func (r *Repository) LogAction(ctx context.Context, id, userID uuid.UUID, actionType, provider string, tokensUsed int, latencyMs int64) error {
    query := `
        INSERT INTO ai_actions (id, user_id, action_type, provider, tokens_used, latency_ms)
        VALUES ($1, $2, $3, $4, $5, $6)
    `
    _, err := r.db.ExecContext(ctx, query, id, userID, actionType, provider, tokensUsed, latencyMs)
    return err
}

func (r *Repository) Ping(ctx context.Context) error {
    return r.db.PingContext(ctx)
}



