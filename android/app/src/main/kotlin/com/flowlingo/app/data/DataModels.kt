package com.flowlingo.app.data

import java.util.UUID

data class SavedPhrase(
    val id: String = UUID.randomUUID().toString(),
    val originalText: String,
    val translatedText: String,
    val sourceLang: String,
    val targetLang: String,
    val timestamp: Long = System.currentTimeMillis()
)

data class UsageRecord(
    val id: String = UUID.randomUUID().toString(),
    val actionType: String, // "translate" or "analyze"
    val inputText: String,
    val outputText: String,
    val timestamp: Long = System.currentTimeMillis()
)
