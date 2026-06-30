package ai

import (
	"context"
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"time"

	"github.com/redis/go-redis/v9"
)

type Cache interface {
	Get(ctx context.Context, key string) (*TranslationResponse, error)
	Set(ctx context.Context, key string, val *TranslationResponse, ttl time.Duration) error
}

type RedisCache struct {
	client *redis.Client
}

func NewRedisCache(url string) *RedisCache {
	opts, err := redis.ParseURL(url)
	if err != nil {
		// Fallback or handle error
		return nil
	}
	return &RedisCache{
		client: redis.NewClient(opts),
	}
}

func (c *RedisCache) Get(ctx context.Context, key string) (*TranslationResponse, error) {
	if c == nil || c.client == nil {
		return nil, fmt.Errorf("cache not configured")
	}
	val, err := c.client.Get(ctx, key).Result()
	if err != nil {
		return nil, err
	}

	var resp TranslationResponse
	if err := json.Unmarshal([]byte(val), &resp); err != nil {
		return nil, err
	}
	return &resp, nil
}

func (c *RedisCache) Set(ctx context.Context, key string, val *TranslationResponse, ttl time.Duration) error {
	if c == nil || c.client == nil {
		return nil
	}
	data, err := json.Marshal(val)
	if err != nil {
		return err
	}
	return c.client.Set(ctx, key, data, ttl).Err()
}

func GenerateCacheKey(req TranslationRequest) string {
	h := sha256.New()
	h.Write([]byte(fmt.Sprintf("%s:%s:%s:%s:%s", req.SourceLang, req.TargetLang, req.Tone, req.Context, req.Text)))
	return fmt.Sprintf("trans:%x", h.Sum(nil))
}
