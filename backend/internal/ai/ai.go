package ai

import (
    "context"
    "fmt"
    "log"
    "time"
)

type TranslationRequest struct {
    Text       string `json:"text"`
    SourceLang string `json:"source_lang"`
    TargetLang string `json:"target_lang"`
    Tone       string `json:"tone"`
    Context    string `json:"context"`
}

type TranslationResponse struct {
    TranslatedText string `json:"translated_text"`
    Provider       string `json:"provider"`
    TokensUsed     int    `json:"tokens_used"`
    LatencyMs      int64  `json:"latency_ms"`
    Cached         bool   `json:"cached"`
}

type AnalysisRequest struct {
    Text     string `json:"text"`
    Language string `json:"language"`
}

type AnalysisResponse struct {
    Analysis         string   `json:"analysis"`
    SuggestedReplies []string `json:"suggested_replies"`
    Provider         string   `json:"provider"`
    TokensUsed       int      `json:"tokens_used"`
    LatencyMs        int64    `json:"latency_ms"`
    Cached           bool     `json:"cached"`
}

type Provider interface {
    Translate(ctx context.Context, req TranslationRequest) (*TranslationResponse, error)
    Analyze(ctx context.Context, req AnalysisRequest) (*AnalysisResponse, error)
    Embed(ctx context.Context, text string) ([]float32, error)
    Name() string
}


type Service struct {
    providers []Provider
    cache     Cache
    scrubber  *Scrubber
}

func NewService(cache Cache, scrubber *Scrubber, providers ...Provider) *Service {
    return &Service{
        providers: providers,
        cache:     cache,
        scrubber:  scrubber,
    }
}

func (s *Service) Translate(ctx context.Context, req TranslationRequest) (*TranslationResponse, error) {
    if s.scrubber != nil {
        req.Text = s.scrubber.Scrub(req.Text)
    }

    cacheKey := "trans:" + GenerateCacheKey(req)
    if s.cache != nil {
        if cached, err := s.cache.Get(ctx, cacheKey); err == nil {
            cached.Cached = true
            return cached, nil
        }
    }

    start := time.Now()
    var lastErr error
    for _, p := range s.providers {
        resp, err := p.Translate(ctx, req)
        if err == nil {
            resp.Provider = p.Name()
            resp.LatencyMs = time.Since(start).Milliseconds()
            if s.cache != nil {
                _ = s.cache.Set(ctx, cacheKey, resp, 24*time.Hour)
            }
            return resp, nil
        }
        log.Printf("provider %s failed translate: %v", p.Name(), err)
        lastErr = err
    }
    return nil, lastErr
}

func (s *Service) Analyze(ctx context.Context, req AnalysisRequest) (*AnalysisResponse, error) {
    if s.scrubber != nil {
        req.Text = s.scrubber.Scrub(req.Text)
    }

    // For analysis, we don't cache as often as translation since it's more contextual, 
    // but we could add it here if needed.

    start := time.Now()
    var lastErr error
    for _, p := range s.providers {
        resp, err := p.Analyze(ctx, req)
        if err == nil {
            resp.Provider = p.Name()
            resp.LatencyMs = time.Since(start).Milliseconds()
            return resp, nil
        }
        log.Printf("provider %s failed analyze: %v", p.Name(), err)
        lastErr = err
    }

    return nil, lastErr
}

func (s *Service) Embed(ctx context.Context, text string) ([]float32, error) {
    for _, p := range s.providers {
        embedding, err := p.Embed(ctx, text)
        if err == nil {
            return embedding, nil
        }
        log.Printf("provider %s failed embed: %v", p.Name(), err)
    }
    return nil, fmt.Errorf("all providers failed to generate embedding")
}

