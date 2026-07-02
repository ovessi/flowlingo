# FlowLingo ProGuard Rules
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keep class com.flowlingo.app.** { *; }
-dontwarn okhttp3.**
-dontwarn retrofit2.**
