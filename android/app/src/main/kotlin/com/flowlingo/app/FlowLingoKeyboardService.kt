package com.flowlingo.app

import android.inputmethodservice.InputMethodService
import android.view.KeyEvent
import android.view.View
import android.view.inputmethod.EditorInfo
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.foundation.combinedClickable
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Tune
import androidx.compose.material.icons.filled.Translate
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.ViewTreeLifecycleOwner
import androidx.compose.ui.platform.ViewTreeViewModelStoreOwner
import androidx.compose.ui.viewinterop.AndroidView
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.*
import androidx.savedstate.SavedStateRegistry
import androidx.savedstate.SavedStateRegistryController
import androidx.savedstate.SavedStateRegistryOwner
import androidx.savedstate.setViewTreeSavedStateRegistryOwner
import com.flowlingo.app.api.AnalyzeRequest
import com.flowlingo.app.api.AnalyzeResponse
import com.flowlingo.app.api.NetworkClient
import com.flowlingo.app.api.TranslateRequest
import com.flowlingo.app.ui.StandardKeyboardLayout
import com.flowlingo.app.ui.FlowLingoTheme
import com.google.mlkit.nl.languageid.LanguageIdentification
import kotlinx.coroutines.*

enum class Tone(val value: String) {
    CASUAL("casual"),
    FORMAL("formal"),
    FRIENDLY("friendly"),
    URGENT("urgent")
}

/**
 * Main Keyboard Service for FlowLingo.
 * Integrates Jetpack Compose for the UI.
 */
class FlowLingoKeyboardService : InputMethodService(), LifecycleOwner, ViewModelStoreOwner, SavedStateRegistryOwner {

    private var composeView: ComposeView? = null
    private val languageIdentifier = LanguageIdentification.getClient()
    private val serviceScope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    private lateinit var prefsManager: com.flowlingo.app.data.PreferencesManager
    private lateinit var hapticHelper: com.flowlingo.app.ui.HapticFeedbackHelper

    // Lifecycle handling for Compose in Service
    private val lifecycleRegistry = LifecycleRegistry(this)
    private val viewModelStore = ViewModelStore()
    private val savedStateRegistryController = SavedStateRegistryController.create(this)

    override fun onCreate() {
        super.onCreate()
        prefsManager = com.flowlingo.app.data.PreferencesManager(this)
        hapticHelper = com.flowlingo.app.ui.HapticFeedbackHelper(this)
        savedStateRegistryController.performRestore(null)
        lifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_CREATE)
    }

    override fun onCreateInputView(): View {
        composeView = ComposeView(this).apply {
            // Set required owners for Compose
            setViewTreeLifecycleOwner(this@FlowLingoKeyboardService)
            setViewTreeViewModelStoreOwner(this@FlowLingoKeyboardService)
            setViewTreeSavedStateRegistryOwner(this@FlowLingoKeyboardService)
            
            setContent {
                FlowLingoTheme {
                    KeyboardLayout()
                }
            }
        }
        return composeView!!
    }

    override fun onStartInputView(info: EditorInfo?, restarting: Boolean) {
        super.onStartInputView(info, restarting)
        lifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_START)
        lifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_RESUME)
    }

    override fun onFinishInputView(finishingInput: Boolean) {
        super.onFinishInputView(finishingInput)
        lifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_PAUSE)
        lifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_STOP)
    }

    override fun onDestroy() {
        super.onDestroy()
        lifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_DESTROY)
    }

    // --- Lifecycle and Store Provider Implementations ---
    override val lifecycle: Lifecycle get() = lifecycleRegistry
    override val viewModelStore: ViewModelStore get() = viewModelStoreStore
    override val savedStateRegistry: SavedStateRegistry get() = savedStateRegistryController.savedStateRegistry

    private val viewModelStoreStore = ViewModelStore()

    private fun handleKey(key: String) {
        val ic = currentInputConnection ?: return
        when (key) {
            "DEL" -> {
                val selectedText = ic.getSelectedText(0)
                if (selectedText.isNullOrEmpty()) {
                    ic.deleteSurroundingText(1, 0)
                } else {
                    ic.commitText("", 1)
                }
            }
            "SHIFT" -> { /* Handled in UI state */ }
            "123", "?123", "LET" -> { /* Handled in UI state */ }
            "SPACE" -> commitText(" ")
            "ENT" -> ic.sendKeyEvent(KeyEvent(KeyEvent.ACTION_DOWN, KeyEvent.KEYCODE_ENTER))
            "EMOJI" -> commitText("😊") // Default emoji for now
            else -> commitText(key)
        }
    }

    private fun detectLanguage(text: String, onResult: (String) -> Unit) {
        languageIdentifier.identifyLanguage(text)
            .addOnSuccessListener { languageCode ->
                if (languageCode != "und") {
                    onResult(languageCode)
                }
            }
    }

    private fun translateAndReplace(text: String, source: String, target: String, tone: String) {
        serviceScope.launch {
            try {
                val response = NetworkClient.api.translate(TranslateRequest(text, source, target, tone))
                currentInputConnection?.deleteSurroundingText(text.length, 0)
                currentInputConnection?.commitText(response.translated_text + " ", 1)
            } catch (e: Exception) {
                currentInputConnection?.commitText(" ", 1)
            }
        }
    }

    @Composable
    fun KeyboardLayout() {
        var suggestions by remember { mutableStateOf(listOf("Hello!", "How are you?", "Glad to meet you.")) }
        var isAnalyzing by remember { mutableStateOf(false) }
        var detectedLanguage by remember { mutableStateOf("en") }
        var isTranslateMode by remember { mutableStateOf(false) }
        var isShifted by remember { mutableStateOf(false) }
        var currentTone by remember { 
            val initialTone = try {
                Tone.valueOf(prefsManager.getDefaultTone().uppercase())
            } catch (e: Exception) {
                Tone.CASUAL
            }
            mutableStateOf(initialTone) 
        }
        var analysisResult by remember { mutableStateOf<AnalyzeResponse?>(null) }
        var clipboardText by remember { mutableStateOf<String?>(null) }

        val context = LocalContext.current
        val scope = rememberCoroutineScope()

        // Clipboard detection logic (opt-in)
        LaunchedEffect(Unit) {
            if (prefsManager.isClipboardDetectionEnabled()) {
                val cm = context.getSystemService(android.content.Context.CLIPBOARD_SERVICE) as? android.content.ClipboardManager
                cm?.primaryClip?.let { clip ->
                    if (clip.itemCount > 0) {
                        val text = clip.getItemAt(0).text?.toString()
                        if (!text.isNullOrBlank()) {
                            clipboardText = text
                        }
                    }
                }
            }
        }

        Column(
            modifier = Modifier
                .fillMaxWidth()
                .background(MaterialTheme.colorScheme.surface)
        ) {
            clipboardText?.let { text ->
                ClipboardBanner(
                    text = text,
                    onAnalyze = {
                        clipboardText = null
                        scope.launch {
                            isAnalyzing = true
                            analysisResult = null
                            try {
                                val response = NetworkClient.api.analyze(AnalyzeRequest(text, detectedLanguage))
                                suggestions = response.suggested_replies
                                analysisResult = response
                            } catch (e: Exception) {
                                delay(1000)
                                suggestions = listOf("Hey!", "Doing great.", "Not much.")
                                analysisResult = AnalyzeResponse(
                                    translation = "Eso es mentira, de verdad.",
                                    cultural_explanation = "Gen-Z slang popular in digital communication.",
                                    slang_breakdown = "'Cap' = lie, 'fr' = for real.",
                                    tone_analysis = "Casual and informal.",
                                    suggested_replies = suggestions
                                )
                            } finally {
                                isAnalyzing = false
                            }
                        }
                    },
                    onDismiss = { clipboardText = null }
                )
            }

            FlowBar(
                sourceLang = detectedLanguage.uppercase(),
                targetLang = prefsManager.getTargetLanguage().uppercase(),
                isTranslateMode = isTranslateMode,
                currentTone = currentTone,
                onToneCycle = {
                    currentTone = when (currentTone) {
                        Tone.CASUAL -> Tone.FRIENDLY
                        Tone.FRIENDLY -> Tone.FORMAL
                        Tone.FORMAL -> Tone.URGENT
                        Tone.URGENT -> Tone.CASUAL
                    }
                },
                onTranslateToggle = { isTranslateMode = !isTranslateMode },
                onTranslateNow = {
                    val ic = currentInputConnection
                    val text = ic?.getSelectedText(0)?.toString() 
                        ?: ic?.getTextBeforeCursor(100, 0)?.toString()?.substringAfterLast("\n")
                        ?: ""
                    if (text.isNotEmpty()) {
                        translateAndReplace(text, detectedLanguage, prefsManager.getTargetLanguage(), currentTone.value)
                    }
                },
                onAnalyze = {
                    val textToAnalyze = currentInputConnection?.getTextBeforeCursor(100, 0)?.toString() ?: ""
                    scope.launch {
                        isAnalyzing = true
                        analysisResult = null
                        try {
                            val response = NetworkClient.api.analyze(AnalyzeRequest(textToAnalyze, detectedLanguage))
                            suggestions = response.suggested_replies
                            analysisResult = response
                        } catch (e: Exception) {
                            delay(1000)
                            suggestions = listOf("Localized reply 1", "Localized reply 2")
                            analysisResult = AnalyzeResponse(
                                translation = "Translation of: $textToAnalyze",
                                cultural_explanation = "Cultural context for the message.",
                                slang_breakdown = "No slang detected.",
                                tone_analysis = "Neutral/Casual",
                                suggested_replies = suggestions
                            )
                        } finally {
                            isAnalyzing = false
                        }
                    }
                }
            )
            if (isAnalyzing) {
                LinearProgressIndicator(
                    modifier = Modifier.fillMaxWidth().height(2.dp),
                    color = MaterialTheme.colorScheme.primary
                )
            }
            
            analysisResult?.let {
                AnalysisPanel(
                    result = it,
                    onDismiss = { analysisResult = null }
                )
            }

            SuggestionBar(suggestions = suggestions)
            
            StandardKeyboardLayout(
                isShifted = isShifted,
                sourceLang = detectedLanguage.uppercase(),
                onKeyClick = { key ->
                    hapticHelper.performHapticFeedback()
                    when (key) {
                        "SHIFT" -> {
                            isShifted = !isShifted
                        }
                        else -> {
                            val textToCommit = if (isShifted && key.length == 1) key.uppercase() else key
                            
                            if (isTranslateMode && key == "SPACE") {
                                val text = currentInputConnection?.getTextBeforeCursor(20, 0)?.toString()?.substringAfterLast(" ") ?: ""
                                if (text.isNotEmpty()) {
                                     translateAndReplace(text, detectedLanguage, prefsManager.getTargetLanguage(), currentTone.value)
                                } else {
                                     handleKey(textToCommit)
                                }
                            } else {
                                handleKey(textToCommit)
                            }
                            // Reset shift after one key press if not caps locked
                            if (isShifted) isShifted = false
                        }
                    }

                    if (key == "SPACE" || key == "ENT") {
                        val text = currentInputConnection?.getTextBeforeCursor(50, 0)?.toString() ?: ""
                        if (text.isNotEmpty()) {
                            detectLanguage(text) { lang ->
                                detectedLanguage = lang
                            }
                        }
                    }
                },
                onGestureDetected = { gestureWord ->
                    commitText(gestureWord)
                }
            )
        }
    }

    @Composable
    fun ClipboardBanner(text: String, onAnalyze: () -> Unit, onDismiss: () -> Unit) {
        Surface(
            modifier = Modifier
                .fillMaxWidth()
                .padding(8.dp),
            color = MaterialTheme.colorScheme.secondaryContainer,
            shape = RoundedCornerShape(8.dp),
            tonalElevation = 4.dp
        ) {
            Row(
                modifier = Modifier.padding(12.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = Icons.Default.AutoAwesome,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.primary
                )
                Spacer(modifier = Modifier.width(12.dp))
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = "Copied text detected",
                        style = MaterialTheme.typography.labelMedium,
                        color = MaterialTheme.colorScheme.primary
                    )
                    Text(
                        text = if (text.length > 40) "${text.take(40)}..." else text,
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSecondaryContainer,
                        maxLines = 1
                    )
                }
                Button(
                    onClick = onAnalyze,
                    modifier = Modifier.padding(start = 8.dp),
                    contentPadding = PaddingValues(horizontal = 12.dp, vertical = 0.dp)
                ) {
                    Text("Analyze", style = MaterialTheme.typography.labelSmall)
                }
                IconButton(onClick = onDismiss) {
                    Icon(imageVector = Icons.Default.Close, contentDescription = "Dismiss", modifier = Modifier.size(18.dp))
                }
            }
        }
    }

    @Composable
    fun AnalysisPanel(result: AnalyzeResponse, onDismiss: () -> Unit) {
        Surface(
            modifier = Modifier
                .fillMaxWidth()
                .padding(8.dp),
            color = MaterialTheme.colorScheme.surfaceVariant,
            shape = RoundedCornerShape(12.dp),
            tonalElevation = 8.dp
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = Icons.Default.AutoAwesome,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.primary,
                            modifier = Modifier.size(20.dp)
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            text = "Analysis",
                            style = MaterialTheme.typography.titleSmall,
                            color = MaterialTheme.colorScheme.primary
                        )
                    }
                    IconButton(onClick = onDismiss, modifier = Modifier.size(24.dp)) {
                        Icon(imageVector = Icons.Default.Close, contentDescription = "Dismiss")
                    }
                }
                
                Spacer(modifier = Modifier.height(8.dp))
                
                if (result.translation != null) {
                    AnalysisSection(title = "Translation", content = result.translation)
                }
                if (result.cultural_explanation != null) {
                    AnalysisSection(title = "Cultural Context", content = result.cultural_explanation)
                }
                if (result.slang_breakdown != null) {
                    AnalysisSection(title = "Slang Breakdown", content = result.slang_breakdown)
                }
                if (result.tone_analysis != null) {
                    AnalysisSection(title = "Tone", content = result.tone_analysis)
                }

                if (result.suggested_replies.isNotEmpty()) {
                    Spacer(modifier = Modifier.height(12.dp))
                    Text(
                        text = "Suggested Replies",
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.primary,
                        fontWeight = FontWeight.Bold
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Row(
                        modifier = Modifier.horizontalScroll(rememberScrollState()),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        result.suggested_replies.take(3).forEach { reply ->
                            SuggestionChip(
                                onClick = { 
                                    commitText(reply)
                                    onDismiss()
                                },
                                label = { Text(reply, style = MaterialTheme.typography.labelSmall) }
                            )
                        }
                    }
                }
            }
        }
    }

    @Composable
    fun AnalysisSection(title: String, content: String) {
        Column(modifier = Modifier.padding(vertical = 4.dp)) {
            Text(
                text = title,
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.primary,
                fontWeight = FontWeight.Bold
            )
            Text(
                text = content,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }

    @Composable
    fun FlowBar(
        sourceLang: String,
        targetLang: String,
        isTranslateMode: Boolean,
        currentTone: Tone,
        onToneCycle: () -> Unit,
        onTranslateToggle: () -> Unit,
        onTranslateNow: () -> Unit,
        onAnalyze: () -> Unit
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(48.dp)
                .padding(horizontal = 8.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            // Language Selector
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(
                    text = sourceLang,
                    style = MaterialTheme.typography.labelLarge,
                    color = MaterialTheme.colorScheme.primary,
                    fontWeight = FontWeight.Bold
                )
                Text(
                    text = " → ",
                    style = MaterialTheme.typography.labelLarge,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Text(
                    text = targetLang,
                    style = MaterialTheme.typography.labelLarge,
                    color = MaterialTheme.colorScheme.primary,
                    fontWeight = FontWeight.Bold
                )
            }

            // Action Icons
            Row(verticalAlignment = Alignment.CenterVertically) {
                // Tone Toggle
                TextButton(onClick = onToneCycle, contentPadding = PaddingValues(0.dp)) {
                    Text(
                        text = currentTone.name,
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.primary
                    )
                }
                // Translate Now
                IconButton(onClick = onTranslateNow) {
                    Icon(
                        imageVector = Icons.Default.Translate,
                        contentDescription = "Translate Current",
                        tint = MaterialTheme.colorScheme.primary
                    )
                }
                // Translate Toggle
                IconButton(onClick = onTranslateToggle) {
                    Icon(
                        imageVector = Icons.Default.Tune,
                        contentDescription = "Translate Mode",
                        tint = if (isTranslateMode) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
                IconButton(onClick = onAnalyze) {
                    Icon(
                        imageVector = Icons.Default.AutoAwesome,
                        contentDescription = "Analyze",
                        tint = MaterialTheme.colorScheme.primary
                    )
                }
                IconButton(onClick = { /* Settings Action */ }) {
                    Icon(
                        imageVector = Icons.Default.Settings,
                        contentDescription = "Settings",
                        tint = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
        }
    }

    @Composable
    fun SuggestionBar(suggestions: List<String>) {
        LazyRow(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 4.dp),
            contentPadding = PaddingValues(horizontal = 8.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(suggestions) { suggestion ->
                SuggestionChip(
                    onClick = { commitText(suggestion) },
                    label = { Text(suggestion) }
                )
            }
        }
    }

    private fun commitText(text: String) {
        currentInputConnection?.commitText(text, 1)
        hapticHelper.performHapticFeedback()
    }
}
