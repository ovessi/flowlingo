package com.flowlingo.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.flowlingo.app.data.PreferencesManager
import com.flowlingo.app.data.SavedPhrase
import com.flowlingo.app.data.UsageRecord
import com.flowlingo.app.ui.FlowLingoTheme

class SettingsActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            FlowLingoTheme {
                MainAppScreen()
            }
        }
    }
}

@Composable
fun MainAppScreen() {
    var currentScreen by remember { mutableStateOf("setup") }
    val context = LocalContext.current
    val prefsManager = remember { PreferencesManager(context) }

    Scaffold(
        bottomBar = {
            NavigationBar {
                NavigationBarItem(
                    icon = { Icon(Icons.Default.Keyboard, contentDescription = null) },
                    label = { Text("Setup") },
                    selected = currentScreen == "setup",
                    onClick = { currentScreen = "setup" }
                )
                NavigationBarItem(
                    icon = { Icon(Icons.Default.Settings, contentDescription = null) },
                    label = { Text("Settings") },
                    selected = currentScreen == "settings",
                    onClick = { currentScreen = "settings" }
                )
                NavigationBarItem(
                    icon = { Icon(Icons.Default.Bookmark, contentDescription = null) },
                    label = { Text("Saved") },
                    selected = currentScreen == "saved",
                    onClick = { currentScreen = "saved" }
                )
                NavigationBarItem(
                    icon = { Icon(Icons.Default.History, contentDescription = null) },
                    label = { Text("History") },
                    selected = currentScreen == "history",
                    onClick = { currentScreen = "history" }
                )
                NavigationBarItem(
                    icon = { Icon(Icons.Default.CameraAlt, contentDescription = null) },
                    label = { Text("Camera") },
                    selected = currentScreen == "camera",
                    onClick = { currentScreen = "camera" }
                )
            }
        }
    ) { innerPadding ->
        Box(modifier = Modifier.padding(innerPadding)) {
            when (currentScreen) {
                "setup" -> SetupScreen()
                "settings" -> SettingsScreen(prefsManager)
                "saved" -> SavedPhrasesScreen()
                "history" -> HistoryScreen()
                "camera" -> CameraTranslationScreen()
            }
        }
    }
}

@Composable
fun SetupScreen() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Icon(
            imageVector = Icons.Default.Keyboard,
            contentDescription = null,
            modifier = Modifier.size(80.dp),
            tint = MaterialTheme.colorScheme.primary
        )
        Spacer(modifier = Modifier.height(24.dp))
        Text(
            text = "Welcome to FlowLingo",
            style = MaterialTheme.typography.headlineMedium,
            fontWeight = FontWeight.Bold
        )
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            text = "Follow the steps below to enable your smart keyboard.",
            style = MaterialTheme.typography.bodyLarge,
            textAlign = androidx.compose.ui.text.style.TextAlign.Center
        )
        Spacer(modifier = Modifier.height(32.dp))
        SetupStep(number = 1, text = "Enable FlowLingo in Settings")
        Spacer(modifier = Modifier.height(16.dp))
        SetupStep(number = 2, text = "Select FlowLingo as default method")
        Spacer(modifier = Modifier.height(32.dp))
        Button(
            onClick = { /* Intent to open keyboard settings */ },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Go to Settings")
        }
    }
}

@Composable
fun SetupStep(number: Int, text: String) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Surface(
            shape = MaterialTheme.shapes.small,
            color = MaterialTheme.colorScheme.primaryContainer,
            modifier = Modifier.size(32.dp)
        ) {
            Box(contentAlignment = Alignment.Center) {
                Text(
                    text = number.toString(),
                    style = MaterialTheme.typography.labelLarge,
                    color = MaterialTheme.colorScheme.onPrimaryContainer
                )
            }
        }
        Spacer(modifier = Modifier.width(16.dp))
        Text(text = text, style = MaterialTheme.typography.bodyLarge)
    }
}

@Composable
fun SettingsScreen(prefsManager: PreferencesManager) {
    var clipboardEnabled by remember { mutableStateOf(prefsManager.isClipboardDetectionEnabled()) }
    var hapticsEnabled by remember { mutableStateOf(prefsManager.isHapticsEnabled()) }

    LazyColumn(
        modifier = Modifier.fillMaxSize()
    ) {
        item {
            Text(
                text = "Preferences",
                style = MaterialTheme.typography.titleLarge,
                modifier = Modifier.padding(16.dp)
            )
        }
        item {
            SettingToggle(
                title = "Clipboard Detection",
                subtitle = "Detect incoming messages in clipboard to offer analysis.",
                icon = Icons.Default.ContentPaste,
                checked = clipboardEnabled,
                onCheckedChange = {
                    clipboardEnabled = it
                    prefsManager.setClipboardDetectionEnabled(it)
                }
            )
        }
        item {
            SettingToggle(
                title = "Haptic Feedback",
                subtitle = "Vibrate on keypress and AI actions.",
                icon = Icons.Default.Vibration,
                checked = hapticsEnabled,
                onCheckedChange = {
                    hapticsEnabled = it
                    prefsManager.setHapticsEnabled(it)
                }
            )
        }
        item {
            Divider(modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp))
        }
        item {
            SettingItem(
                title = "Default Tone",
                subtitle = prefsManager.getDefaultTone().capitalize(),
                icon = Icons.Default.Tune
            )
        }
        item {
            SettingItem(
                title = "Target Language",
                subtitle = prefsManager.getTargetLanguage().uppercase(),
                icon = Icons.Default.Translate
            )
        }
        item {
            SettingItem(
                title = "Camera Translation",
                subtitle = "Setup ML Kit OCR",
                icon = Icons.Default.CameraAlt
            )
        }
    }
}

@Composable
fun SettingToggle(
    title: String,
    subtitle: String,
    icon: ImageVector,
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onCheckedChange(!checked) }
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(imageVector = icon, contentDescription = null, tint = MaterialTheme.colorScheme.primary)
        Spacer(modifier = Modifier.width(16.dp))
        Column(modifier = Modifier.weight(1f)) {
            Text(text = title, style = MaterialTheme.typography.bodyLarge, fontWeight = FontWeight.Medium)
            Text(text = subtitle, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
        }
        Switch(checked = checked, onCheckedChange = onCheckedChange)
    }
}

@Composable
fun SettingItem(title: String, subtitle: String, icon: ImageVector) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { /* Handle click */ }
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(imageVector = icon, contentDescription = null, tint = MaterialTheme.colorScheme.primary)
        Spacer(modifier = Modifier.width(16.dp))
        Column {
            Text(text = title, style = MaterialTheme.typography.bodyLarge, fontWeight = FontWeight.Medium)
            Text(text = subtitle, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
        }
    }
}

@Composable
fun SavedPhrasesScreen() {
    val savedPhrases = remember {
        listOf(
            SavedPhrase(originalText = "Hello, how are you?", translatedText = "こんにちは、お元気ですか？", sourceLang = "EN", targetLang = "JP"),
            SavedPhrase(originalText = "I'm on my way.", translatedText = "今向かっています。", sourceLang = "EN", targetLang = "JP")
        )
    }

    LazyColumn(modifier = Modifier.fillMaxSize()) {
        item {
            Text(
                text = "Saved Phrases",
                style = MaterialTheme.typography.titleLarge,
                modifier = Modifier.padding(16.dp)
            )
        }
        items(savedPhrases) { phrase ->
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 8.dp),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text(text = "${phrase.sourceLang} → ${phrase.targetLang}", style = MaterialTheme.typography.labelSmall)
                        Icon(imageVector = Icons.Default.Star, contentDescription = null, tint = MaterialTheme.colorScheme.primary, modifier = Modifier.size(16.dp))
                    }
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(text = phrase.originalText, style = MaterialTheme.typography.bodyMedium, fontWeight = FontWeight.Bold)
                    Text(text = phrase.translatedText, style = MaterialTheme.typography.bodyMedium, color = MaterialTheme.colorScheme.primary)
                }
            }
        }
    }
}

@Composable
fun HistoryScreen() {
    val history = remember {
        listOf(
            UsageRecord(actionType = "translate", inputText = "Where is the station?", outputText = "駅はどこですか？"),
            UsageRecord(actionType = "analyze", inputText = "That's fire!", outputText = "Cultural Context: Gen-Z slang for 'excellent'.")
        )
    }

    LazyColumn(modifier = Modifier.fillMaxSize()) {
        item {
            Text(
                text = "Usage History",
                style = MaterialTheme.typography.titleLarge,
                modifier = Modifier.padding(16.dp)
            )
        }
        items(history) { record ->
            ListItem(
                headlineContent = { Text(record.inputText) },
                supportingContent = { Text(record.outputText) },
                leadingContent = {
                    Icon(
                        imageVector = if (record.actionType == "translate") Icons.Default.Translate else Icons.Default.AutoAwesome,
                        contentDescription = null
                    )
                },
                trailingContent = {
                    Text(
                        text = "Just now",
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            )
            Divider()
        }
    }
}

@Composable
fun CameraTranslationScreen() {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Icon(
            imageVector = Icons.Default.CameraAlt,
            contentDescription = null,
            modifier = Modifier.size(80.dp),
            tint = MaterialTheme.colorScheme.primary
        )
        Spacer(modifier = Modifier.height(24.dp))
        Text(
            text = "Camera Translation",
            style = MaterialTheme.typography.headlineMedium,
            fontWeight = FontWeight.Bold
        )
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            text = "Point your camera at text to translate it instantly using ML Kit OCR.",
            style = MaterialTheme.typography.bodyLarge,
            textAlign = androidx.compose.ui.text.style.TextAlign.Center
        )
        Spacer(modifier = Modifier.height(32.dp))
        Button(
            onClick = { /* Open Camera Logic */ },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Open Camera")
        }
        Spacer(modifier = Modifier.height(16.dp))
        OutlinedButton(
            onClick = { /* Import from Gallery */ },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Import from Gallery")
        }
    }
}
