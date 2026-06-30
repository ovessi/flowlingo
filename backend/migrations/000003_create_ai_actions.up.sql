CREATE TABLE IF NOT EXISTS ai_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    action_type VARCHAR(50) NOT NULL, -- 'translate', 'suggest', 'analyze'
    provider VARCHAR(50) NOT NULL,
    tokens_used INTEGER,
    latency_ms INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_actions_user_created ON ai_actions(user_id, created_at);
