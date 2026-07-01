package ai

import (
    "context"
    "encoding/json"
    "fmt"

    "github.com/google/generative-ai-go/genai"
    "google.golang.org/api/option"
)

type GeminiProvider struct {
    client *genai.Client
    model  string
}

func NewGeminiProvider(ctx context.Context, apiKey string, modelName string) (*GeminiProvider, error) {
    client, err := genai.NewClient(ctx, option.WithAPIKey(apiKey))
    if err != nil {
        return nil, err
    }
    return &GeminiProvider{
        client: client,
        model:  modelName,
    }, nil
}

func (p *GeminiProvider) Translate(ctx context.Context, req TranslationRequest) (*TranslationResponse, error) {
    model := p.client.GenerativeModel(p.model)
    prompt := fmt.Sprintf(
        "Translate the following text from %s to %s. Tone: %s. Context: %s\n\nText: %s",
        req.SourceLang, req.TargetLang, req.Tone, req.Context, req.Text,
    )

    resp, err := model.GenerateContent(ctx, genai.Text(prompt))
    if err != nil {
        return nil, err
    }

    if len(resp.Candidates) == 0 || len(resp.Candidates[0].Content.Parts) == 0 {
        return nil, fmt.Errorf("empty response from gemini")
    }

    part := resp.Candidates[0].Content.Parts[0]
    text, ok := part.(genai.Text)
    if !ok {
        return nil, fmt.Errorf("unexpected response type from gemini")
    }

    return &TranslationResponse{
        TranslatedText: string(text),
        TokensUsed:     0, // Gemini Go SDK usage info is complex to extract from simple call
    }, nil
}

func (p *GeminiProvider) Analyze(ctx context.Context, req AnalysisRequest) (*AnalysisResponse, error) {
    model := p.client.GenerativeModel(p.model)
    // Force JSON response
    model.ResponseMIMEType = "application/json"

    prompt := fmt.Sprintf(
        "Analyze the following text in %s. Provide cultural context, slang explanation, and 3 suggested replies in different tones (casual, friendly, professional). Return as JSON format:\n\n{ \"analysis\": \"...\", \"suggested_replies\": [\"...\", \"...\", \"...\"] }\n\nText: %s",
        req.Language, req.Text,
    )

    resp, err := model.GenerateContent(ctx, genai.Text(prompt))
    if err != nil {
        return nil, err
    }

    if len(resp.Candidates) == 0 || len(resp.Candidates[0].Content.Parts) == 0 {
        return nil, fmt.Errorf("empty response from gemini")
    }

    part := resp.Candidates[0].Content.Parts[0]
    text, ok := part.(genai.Text)
    if !ok {
        return nil, fmt.Errorf("unexpected response type from gemini")
    }

    var result struct {
        Analysis         string   `json:"analysis"`
        SuggestedReplies []string `json:"suggested_replies"`
    }
    if err := json.Unmarshal([]byte(text), &result); err != nil {
        return nil, err
    }

    return &AnalysisResponse{
        Analysis:         result.Analysis,
        SuggestedReplies: result.SuggestedReplies,
        TokensUsed:       0,
    }, nil
}

func (p *GeminiProvider) Embed(ctx context.Context, text string) ([]float32, error) {
    model := p.client.EmbeddingModel("text-embedding-004")
    res, err := model.EmbedContent(ctx, genai.Text(text))
    if err != nil {
        return nil, err
    }
    return res.Embedding.Values, nil
}

func (p *GeminiProvider) Name() string {
    return "gemini"
}
