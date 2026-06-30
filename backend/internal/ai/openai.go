package ai

import (
    "context"
    "encoding/json"
    "fmt"

    "github.com/sashabaranov/go-openai"
)

type OpenAIProvider struct {
    client *openai.Client
    model  string
}

func NewOpenAIProvider(apiKey string, model string) *OpenAIProvider {
    return &OpenAIProvider{
        client: openai.NewClient(apiKey),
        model:  model,
    }
}

func (p *OpenAIProvider) Translate(ctx context.Context, req TranslationRequest) (*TranslationResponse, error) {
    prompt := fmt.Sprintf(
        "Translate the following text from %s to %s. Tone: %s. Context: %s\n\nText: %s",
        req.SourceLang, req.TargetLang, req.Tone, req.Context, req.Text,
    )

    resp, err := p.client.CreateChatCompletion(ctx, openai.ChatCompletionRequest{
        Model: p.model,
        Messages: []openai.ChatCompletionMessage{
            {
                Role:    openai.ChatMessageRoleSystem,
                Content: "You are a professional translator for FlowLingo. Provide only the translated text.",
            },
            {
                Role:    openai.ChatMessageRoleUser,
                Content: prompt,
            },
        },
    })
    if err != nil {
        return nil, err
    }

    return &TranslationResponse{
        TranslatedText: resp.Choices[0].Message.Content,
        TokensUsed:     resp.Usage.TotalTokens,
    }, nil
}

func (p *OpenAIProvider) Analyze(ctx context.Context, req AnalysisRequest) (*AnalysisResponse, error) {
    prompt := fmt.Sprintf(
        "Analyze the following text in %s. Provide cultural context, slang explanation, and 3 suggested replies in different tones (casual, friendly, professional). Return as JSON format:\n\n{ \"analysis\": \"...\", \"suggested_replies\": [\"...\", \"...\", \"...\"] }\n\nText: %s",
        req.Language, req.Text,
    )

    resp, err := p.client.CreateChatCompletion(ctx, openai.ChatCompletionRequest{
        Model: p.model,
        ResponseFormat: &openai.ChatCompletionResponseFormat{
            Type: openai.ChatCompletionResponseFormatTypeJSONObject,
        },
        Messages: []openai.ChatCompletionMessage{
            {
                Role:    openai.ChatMessageRoleSystem,
                Content: "You are a communication expert. Return JSON.",
            },
            {
                Role:    openai.ChatMessageRoleUser,
                Content: prompt,
            },
        },
    })
    if err != nil {
        return nil, err
    }

    var result struct {
        Analysis         string   `json:"analysis"`
        SuggestedReplies []string `json:"suggested_replies"`
    }
    if err := json.Unmarshal([]byte(resp.Choices[0].Message.Content), &result); err != nil {
        return nil, err
    }

    return &AnalysisResponse{
        Analysis:         result.Analysis,
        SuggestedReplies: result.SuggestedReplies,
        TokensUsed:       resp.Usage.TotalTokens,
    }, nil
}

func (p *OpenAIProvider) Embed(ctx context.Context, text string) ([]float32, error) {
    resp, err := p.client.CreateEmbeddings(ctx, openai.EmbeddingRequest{
        Input: []string{text},
        Model: openai.AdaEmbeddingV2, // 1536 dimensions
    })
    if err != nil {
        return nil, err
    }
    return resp.Data[0].Embedding, nil
}

func (p *OpenAIProvider) Name() string {
    return "openai"
}
