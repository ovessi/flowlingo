package com.flowlingo.app.ui

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import com.flowlingo.app.data.PreferencesManager

class HapticFeedbackHelper(context: Context) {
    private val vibrator = context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
    private val prefsManager = PreferencesManager(context)

    fun performHapticFeedback() {
        if (!prefsManager.isHapticsEnabled()) return

        val effect = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            VibrationEffect.createPredefined(VibrationEffect.EFFECT_CLICK)
        } else {
            @Suppress("DEPRECATION")
            VibrationEffect.createOneShot(10, VibrationEffect.DEFAULT_AMPLITUDE)
        }
        vibrator?.vibrate(effect)
    }
}
