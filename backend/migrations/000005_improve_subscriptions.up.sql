ALTER TABLE subscriptions ADD COLUMN IF NOT EXISTS platform VARCHAR(20);
ALTER TABLE subscriptions ADD COLUMN IF NOT EXISTS external_subscription_id VARCHAR(255);

-- Ensure one subscription entry per user for simple entitlement check
-- If a user changes platform, we update this row.
CREATE UNIQUE INDEX IF NOT EXISTS idx_subscriptions_user_id_unique ON subscriptions(user_id);
