package com.flowlingo.app.data

import android.content.Context
import android.content.SharedPreferences

class PreferencesManager(context: Context) {
    private val sharedPreferences: SharedPreferences =
        context.getSharedPreferences("flowlingo_prefs", Context.MODE_PRIVATE)

    fun isClipboardDetectionEnabled(): Boolean {
        return sharedPreferences.getBoolean("clipboard_detection_enabled", false)
    }

    fun setClipboardDetectionEnabled(enabled: Boolean) {
        sharedPreferences.edit().putBoolean("clipboard_detection_enabled", enabled).apply()
    }

    fun getDefaultTone(): String {
        return sharedPreferences.getString("default_tone", "casual") ?: "casual"
    }

    fun setDefaultTone(tone: String) {
        sharedPreferences.edit().putString("default_tone", tone).apply()
    }

    fun getTargetLanguage(): String {
        return sharedPreferences.getString("target_lang", "ja") ?: "ja"
    }

    fun setTargetLanguage(lang: String) {
        sharedPreferences.edit().putString("target_lang", lang).apply()
    }

    fun isHapticsEnabled(): Boolean {
        return sharedPreferences.getBoolean("haptics_enabled", true)
    }

    fun setHapticsEnabled(enabled: Boolean) {
        sharedPreferences.edit().putBoolean("haptics_enabled", enabled).apply()
    }
}
