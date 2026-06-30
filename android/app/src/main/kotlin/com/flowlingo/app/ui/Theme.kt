package com.flowlingo.app.ui

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.sp

@Composable
fun FlowLingoTheme(content: @Composable () -> Unit) {
    val darkTheme = isSystemInDarkTheme()
    val colorScheme = if (darkTheme) {
        darkColorScheme(
            primary = Color(0xFF4F46E5), // Indigo 600
            secondary = Color(0xFF10B981), // Emerald 500
            background = Color(0xFF111827),
            surface = Color(0xFF1F2937),
            onSurface = Color(0xFFF9FAFB),
            onSurfaceVariant = Color(0xFF9CA3AF)
        )
    } else {
        lightColorScheme(
            primary = Color(0xFF4F46E5), // Indigo 600
            secondary = Color(0xFF10B981), // Emerald 500
            background = Color(0xFFFFFFFF),
            surface = Color(0xFFF3F4F6),
            onSurface = Color(0xFF111827),
            onSurfaceVariant = Color(0xFF6B7280)
        )
    }

    val typography = Typography(
        bodyLarge = androidx.compose.ui.text.TextStyle(
            fontFamily = androidx.compose.ui.text.font.FontFamily.Default,
            fontWeight = androidx.compose.ui.text.font.FontWeight.Normal,
            fontSize = 16.sp,
            lineHeight = 24.sp,
            letterSpacing = 0.5.sp
        ),
        labelLarge = androidx.compose.ui.text.TextStyle(
            fontFamily = androidx.compose.ui.text.font.FontFamily.Default,
            fontWeight = androidx.compose.ui.text.font.FontWeight.Medium,
            fontSize = 14.sp,
            lineHeight = 20.sp,
            letterSpacing = 0.1.sp
        )
    )

    MaterialTheme(
        colorScheme = colorScheme,
        typography = typography,
        content = content
    )
}
