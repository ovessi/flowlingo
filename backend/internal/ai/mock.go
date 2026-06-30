package ai

import (
    "context"
    "fmt"
)

type MockProvider struct{}

func (p *MockProvider) Translate(ctx context.Context, req TranslationRequest) (*TranslationResponse, error) {
    translated := fmt.Sprintf("[Mock %s -> %s, Tone: %s] %s", req.SourceLang, req.TargetLang, req.Tone, req.Text)
    return &TranslationResponse{
        TranslatedText: translated,
        TokensUsed:     len(req.Text) / 4, // Rough estimate
    }, nil
}

func (p *MockProvider) Analyze(ctx context.Context, req AnalysisRequest) (*AnalysisResponse, error) {
    return &AnalysisResponse{
        Analysis: "This is a mock analysis of the message. It explains cultural context and slang.",
        SuggestedReplies: []string{
            "Cool!",
            "Nice to meet you.",
            "Let's grab a coffee.",
        },
        TokensUsed: len(req.Text) / 2,
    }, nil
}

func (p *MockProvider) Embed(ctx context.Context, text string) ([]float32, error) {
    // Return a mock embedding of size 1536
    embedding := make([]float32, 1536)
    for i := range embedding {
        embedding[i] = 0.1 * float32(i)
    }
    return embedding, nil
}

func (p *MockProvider) Name() string {
    return "mock"
}
