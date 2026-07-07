package com.flowlingo.app

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.flowlingo.app.api.AnalyzeRequest
import com.flowlingo.app.api.AnalyzeResponse
import com.flowlingo.app.api.NetworkClient
import com.flowlingo.app.ui.FlowLingoTheme
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class ShareActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val sharedText = if (intent?.action == Intent.ACTION_SEND && intent.type == "text/plain") {
            intent.getStringExtra(Intent.EXTRA_TEXT)
        } else null

        setContent {
            FlowLingoTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    ShareScreen(sharedText)
                }
            }
        }
    }
}

@Composable
fun ShareScreen(text: String?) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    var isAnalyzing by remember { mutableStateOf(false) }
    var analysisResult by remember { mutableStateOf<AnalyzeResponse?>(null) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        if (text != null) {
            Text(
                text = "Analyze Shared Text",
                style = MaterialTheme.typography.headlineSmall
            )
            Spacer(modifier = Modifier.height(16.dp))
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)
            ) {
                Text(
                    text = text,
                    modifier = Modifier.padding(16.dp),
                    style = MaterialTheme.typography.bodyMedium
                )
            }
            Spacer(modifier = Modifier.height(24.dp))

            if (isAnalyzing) {
                CircularProgressIndicator(
                    modifier = Modifier.size(48.dp),
                    color = MaterialTheme.colorScheme.primary
                )
                Spacer(modifier = Modifier.height(16.dp))
                Text(
                    text = "Analyzing...",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            analysisResult?.let { result ->
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text(
                            text = "Analysis Results",
                            style = MaterialTheme.typography.titleSmall,
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colorScheme.primary
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        result.translation?.let {
                            Text("Translation:", style = MaterialTheme.typography.labelSmall, fontWeight = FontWeight.Bold)
                            Text(it, style = MaterialTheme.typography.bodySmall)
                            Spacer(modifier = Modifier.height(4.dp))
                        }
                        result.tone_analysis?.let {
                            Text("Tone:", style = MaterialTheme.typography.labelSmall, fontWeight = FontWeight.Bold)
                            Text(it, style = MaterialTheme.typography.bodySmall)
                        }
                    }
                }
                Spacer(modifier = Modifier.height(16.dp))
            }

            Button(
                onClick = {
                    scope.launch {
                        isAnalyzing = true
                        analysisResult = null
                        try {
                            val response = NetworkClient.api.analyze(AnalyzeRequest(text, "en"))
                            analysisResult = response
                        } catch (e: Exception) {
                            delay(1000)
                            analysisResult = AnalyzeResponse(
                                translation = "Mock translation (server unavailable).",
                                cultural_explanation = "Connect to server for cultural analysis.",
                                slang_breakdown = "No slang analysis available offline.",
                                tone_analysis = "Tone analysis requires server connection.",
                                suggested_replies = emptyList()
                            )
                        } finally {
                            isAnalyzing = false
                        }
                    }
                },
                modifier = Modifier.fillMaxWidth(),
                enabled = !isAnalyzing
            ) {
                Text("Analyze with FlowLingo")
            }
        } else {
            Text(
                text = "No text shared.",
                style = MaterialTheme.typography.bodyLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Spacer(modifier = Modifier.height(16.dp))
            Button(
                onClick = { (context as? ComponentActivity)?.finish() },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("Go Back")
            }
        }
    }
}
