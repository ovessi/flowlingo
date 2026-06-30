package ai

import (
    "bytes"
    "context"
    "encoding/json"
    "fmt"
    "net/http"
)

type AnthropicProvider struct {
    apiKey string
    model  string
}

func NewAnthropicProvider(apiKey string, model string) *AnthropicProvider {
    return &AnthropicProvider{
        apiKey: apiKey,
        model:  model,
    }
}

type anthropicRequest struct {
    Model     string             `json:"model"`
    Messages  []anthropicMessage `json:"messages"`
    MaxTokens int                `json:"max_tokens"`
}

type anthropicMessage struct {
    Role    string `json:"role"`
    Content string `json:"content"`
}

type anthropicResponse struct {
    Content []struct {
        Text string `json:"text"`
    } `json:"content"`
    Usage struct {
        InputTokens  int `json:"input_tokens"`
        OutputTokens int `json:"output_tokens"`
    } `json:"usage"`
}

func (p *AnthropicProvider) Translate(ctx context.Context, req TranslationRequest) (*TranslationResponse, error) {
    prompt := fmt.Sprintf(
        "Translate the following text from %s to %s. Tone: %s. Context: %s\n\nText: %s",
        req.SourceLang, req.TargetLang, req.Tone, req.Context, req.Text,
    )

    body := anthropicRequest{
        Model: p.model,
        Messages: []anthropicMessage{
            {Role: "user", Content: prompt},
        },
        MaxTokens: 1024,
    }

    jsonBody, _ := json.Marshal(body)
    httpReq, err := http.NewRequestWithContext(ctx, "POST", "https://api.anthropic.com/v1/messages", bytes.NewBuffer(jsonBody))
    if err != nil {
        return nil, err
    }

    httpReq.Header.Set("Content-Type", "application/json")
    httpReq.Header.Set("x-api-key", p.apiKey)
    httpReq.Header.Set("anthropic-version", "2023-06-01")

    client := &http.Client{}
    resp, err := client.Do(httpReq)
    if err != nil {
        return nil, err
    }
    defer resp.Body.Close()

    if resp.StatusCode != http.StatusOK {
        return nil, fmt.Errorf("anthropic error: status %d", resp.StatusCode)
    }

    var anthropicResp anthropicResponse
    if err := json.NewDecoder(resp.Body).Decode(&anthropicResp); err != nil {
        return nil, err
    }

    if len(anthropicResp.Content) == 0 {
        return nil, fmt.Errorf("empty response from anthropic")
    }

    return &TranslationResponse{
        TranslatedText: anthropicResp.Content[0].Text,
        TokensUsed:     anthropicResp.Usage.InputTokens + anthropicResp.Usage.OutputTokens,
    }, nil
}

func (p *AnthropicProvider) Analyze(ctx context.Context, req AnalysisRequest) (*AnalysisResponse, error) {
    prompt := fmt.Sprintf(
        "Analyze the following text in %s. Provide cultural context, slang explanation, and 3 suggested replies in different tones (casual, friendly, professional). Return as JSON format only:\n\n{ \"analysis\": \"...\", \"suggested_replies\": [\"...\", \"...\", \"...\"] }\n\nText: %s",
        req.Language, req.Text,
    )

    body := anthropicRequest{
        Model: p.model,
        Messages: []anthropicMessage{
            {Role: "user", Content: prompt},
        },
        MaxTokens: 1024,
    }

    jsonBody, _ := json.Marshal(body)
    httpReq, err := http.NewRequestWithContext(ctx, "POST", "https://api.anthropic.com/v1/messages", bytes.NewBuffer(jsonBody))
    if err != nil {
        return nil, err
    }

    httpReq.Header.Set("Content-Type", "application/json")
    httpReq.Header.Set("x-api-key", p.apiKey)
    httpReq.Header.Set("anthropic-version", "2023-06-01")

    client := &http.Client{}
    resp, err := client.Do(httpReq)
    if err != nil {
        return nil, err
    }
    defer resp.Body.Close()

    if resp.StatusCode != http.StatusOK {
        return nil, fmt.Errorf("anthropic error: status %d", resp.StatusCode)
    }

    var anthropicResp anthropicResponse
    if err := json.NewDecoder(resp.Body).Decode(&anthropicResp); err != nil {
        return nil, err
    }

    if len(anthropicResp.Content) == 0 {
        return nil, fmt.Errorf("empty response from anthropic")
    }

    var result struct {
        Analysis         string   `json:"analysis"`
        SuggestedReplies []string `json:"suggested_replies"`
    }
    if err := json.Unmarshal([]byte(anthropicResp.Content[0].Text), &result); err != nil {
        return nil, err
    }

    return &AnalysisResponse{
        Analysis:         result.Analysis,
        SuggestedReplies: result.SuggestedReplies,
        TokensUsed:       anthropicResp.Usage.InputTokens + anthropicResp.Usage.OutputTokens,
    }, nil
}

func (p *AnthropicProvider) Embed(ctx context.Context, text string) ([]float32, error) {
    return nil, fmt.Errorf("anthropic does not support embeddings")
}

func (p *AnthropicProvider) Name() string {
    return "anthropic"
}
