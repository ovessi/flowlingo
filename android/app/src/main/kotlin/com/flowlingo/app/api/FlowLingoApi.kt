package com.flowlingo.app.api

import retrofit2.http.Body
import retrofit2.http.POST

data class TranslateRequest(
    val text: String,
    val source_lang: String,
    val target_lang: String,
    val tone: String,
    val context: String? = null
)

data class TranslateResponse(
    val translated_text: String,
    val action_id: String,
    val credits_remaining: Int
)

data class AnalyzeRequest(
    val text: String,
    val language: String
)

data class AnalyzeResponse(
    val translation: String? = null,
    val cultural_explanation: String? = null,
    val slang_breakdown: String? = null,
    val tone_analysis: String? = null,
    val suggested_replies: List<String>
)

interface FlowLingoApi {
    @POST("/v1/ai/translate")
    suspend fun translate(@Body request: TranslateRequest): TranslateResponse

    @POST("/v1/ai/analyze")
    suspend fun analyze(@Body request: AnalyzeRequest): AnalyzeResponse
}
