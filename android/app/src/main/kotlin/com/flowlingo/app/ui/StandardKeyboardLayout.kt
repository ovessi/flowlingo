package com.flowlingo.app.ui

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.EmojiEmotions
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

enum class KeyboardLayer {
    LETTERS, SYMBOLS, SYMBOLS_SHIFT
}

@Composable
fun StandardKeyboardLayout(
    isShifted: Boolean = false,
    sourceLang: String = "EN",
    onKeyClick: (String) -> Unit,
    onGestureDetected: (String) -> Unit = {}
) {
    var currentLayer by remember { mutableStateOf(KeyboardLayer.LETTERS) }
    
    val numberRow = listOf("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
    
    val letterRows = listOf(
        listOf("q", "w", "e", "r", "t", "y", "u", "i", "o", "p"),
        listOf("a", "s", "d", "f", "g", "h", "j", "k", "l"),
        listOf("SHIFT", "z", "x", "c", "v", "b", "n", "m", "DEL")
    )
    
    val symbolRows = listOf(
        listOf("1", "2", "3", "4", "5", "6", "7", "8", "9", "0"),
        listOf("@", "#", "$", "%", "&", "-", "+", "(", ")"),
        listOf("=\\<", "*", "\"", "'", ":", ";", "!", "?", "DEL")
    )

    val symbolShiftRows = listOf(
        listOf("~", "`", "|", "•", "√", "π", "÷", "×", "{", "}"),
        listOf("£", "¥", "$", "¢", "^", "°", "=", "[", "]"),
        listOf("?123", "™", "®", "©", "¶", "\\", "¡", "¿", "DEL")
    )

    val bottomRow = listOf("?123", "emoji", ",", "SPACE", ".", "ENT")

    var gesturePoints by remember { mutableStateOf(listOf<Offset>()) }

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .pointerInput(Unit) {
                detectDragGestures(
                    onDragStart = { offset ->
                        gesturePoints = listOf(offset)
                    },
                    onDrag = { change, dragAmount ->
                        change.consume()
                        gesturePoints = gesturePoints + change.position
                    },
                    onDragEnd = {
                        if (gesturePoints.size > 5) {
                            onGestureDetected("gesture")
                        }
                        gesturePoints = listOf()
                    }
                )
            }
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(4.dp),
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            // Number Row
            KeyboardRow(keys = numberRow, onKeyClick = onKeyClick)

            // Main Rows
            val rows = when (currentLayer) {
                KeyboardLayer.LETTERS -> letterRows
                KeyboardLayer.SYMBOLS -> symbolRows
                KeyboardLayer.SYMBOLS_SHIFT -> symbolShiftRows
            }

            rows.forEach { row ->
                KeyboardRow(
                    keys = row,
                    isShifted = isShifted && currentLayer == KeyboardLayer.LETTERS,
                    onKeyClick = { key ->
                        when (key) {
                            "=\\<" -> currentLayer = KeyboardLayer.SYMBOLS_SHIFT
                            "?123" -> if (currentLayer == KeyboardLayer.SYMBOLS_SHIFT) currentLayer = KeyboardLayer.SYMBOLS
                            else -> onKeyClick(key)
                        }
                    }
                )
            }

            // Bottom Row
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                bottomRow.forEach { key ->
                    val weight = when (key) {
                        "SPACE" -> 4f
                        "ENT", "?123" -> 1.5f
                        else -> 1f
                    }
                    
                    Box(
                        modifier = Modifier
                            .weight(weight)
                            .height(56.dp)
                            .clip(RoundedCornerShape(6.dp))
                            .background(MaterialTheme.colorScheme.surfaceVariant)
                            .clickable {
                                when (key) {
                                    "?123" -> {
                                        currentLayer = if (currentLayer == KeyboardLayer.LETTERS) {
                                            KeyboardLayer.SYMBOLS
                                        } else {
                                            KeyboardLayer.LETTERS
                                        }
                                    }
                                    "emoji" -> onKeyClick("EMOJI")
                                    else -> onKeyClick(key)
                                }
                            },
                        contentAlignment = Alignment.Center
                    ) {
                        when (key) {
                            "emoji" -> Icon(
                                imageVector = Icons.Default.EmojiEmotions,
                                contentDescription = "Emoji",
                                tint = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                            "SPACE" -> Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                Text(text = " ", fontSize = 12.sp)
                                Text(
                                    text = sourceLang,
                                    style = MaterialTheme.typography.labelSmall,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.6f)
                                )
                            }
                            else -> Text(
                                text = key,
                                style = MaterialTheme.typography.bodyLarge,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
                }
            }
        }
        
        // Gesture Trail
        val primaryColor = MaterialTheme.colorScheme.primary
        Canvas(modifier = Modifier.matchParentSize()) {
            if (gesturePoints.size > 1) {
                for (i in 0 until gesturePoints.size - 1) {
                    drawLine(
                        color = primaryColor.copy(alpha = 0.5f),
                        start = gesturePoints[i],
                        end = gesturePoints[i + 1],
                        strokeWidth = 8f,
                        cap = StrokeCap.Round
                    )
                }
            }
        }
    }
}

@Composable
fun KeyboardRow(
    keys: List<String>,
    isShifted: Boolean = false,
    onKeyClick: (String) -> Unit
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        keys.forEach { key ->
            val weight = when (key) {
                "SHIFT", "DEL", "LET" -> 1.5f
                else -> 1f
            }
            val displayText = if (isShifted && key.length == 1) key.uppercase() else key
            KeyboardKey(
                text = displayText,
                modifier = Modifier.weight(weight),
                onClick = { onKeyClick(key) }
            )
        }
    }
}

@Composable
fun KeyboardKey(
    text: String,
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
    Box(
        modifier = modifier
            .height(56.dp)
            .semantics { contentDescription = text }
            .clip(RoundedCornerShape(6.dp))
            .background(MaterialTheme.colorScheme.surfaceVariant)
            .clickable { onClick() },
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = text,
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}
