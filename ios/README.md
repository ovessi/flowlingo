# FlowLingo iOS

The iOS client for FlowLingo — an AI communication platform built as a smart keyboard.

## Architecture

```
FlowLingo.xcodeproj
├── FlowLingo/                    # Companion App (SwiftUI)
│   ├── App/
│   │   ├── FlowLingoApp.swift    # @main entry point
│   │   ├── ContentView.swift     # Root view (onboarding → tabs)
│   │   ├── AppDelegate.swift     # App lifecycle
│   │   └── SceneDelegate.swift   # Scene management
│   ├── UI/
│   │   ├── Views/
│   │   │   ├── OnboardingView.swift    # Setup tutorial
│   │   │   ├── SettingsView.swift      # Preferences dashboard
│   │   │   └── ProfileView.swift       # Account & stats
│   │   └── Components/
│   │       └── ...                      # Reusable SwiftUI components
│   └── Services/
│       └── ...                          # App-level services
│
├── KeyboardExtension/            # Keyboard Extension (UIKit)
│   ├── KeyboardViewController.swift    # Primary controller
│   ├── FlowBar/
│   │   ├── FlowBarView.swift           # Main action bar container
│   │   ├── LanguageSelectorView.swift  # Source → Target display
│   │   ├── ToneToggleView.swift        # Formal/Casual/Friendly/Urgent
│   │   ├── AnalyzeButtonView.swift     # AI sparkle button
│   │   └── SettingsButtonView.swift    # Gear icon
│   ├── Suggestions/
│   │   └── SuggestionChipsView.swift   # AI-reply chips
│   ├── Clipboard/
│   │   └── ClipboardDetectionService.swift  # Privacy-first clipboard
│   ├── Views/
│   │   ├── StatusIndicatorView.swift   # Thinking dot, offline banner
│   │   └── AnalyzeBannerView.swift     # Clipboard content banner
│   ├── Services/
│   │   ├── ThemeService.swift          # Dark/Light mode, design tokens
│   │   ├── HapticFeedbackService.swift # Premium haptics
│   │   └── APIClient.swift            # Network layer + Keychain
│   └── Resources/
│       └── Info.plist                  # Keyboard extension config
│
├── ShareExtension/               # Share Extension (UIKit)
│   ├── ShareViewController.swift      # Share sheet handler
│   └── Info.plist
│
├── WidgetExtension/              # Today Widget (SwiftUI)
│   ├── FlowLingoWidget.swift          # Stats + language toggle
│   └── Info.plist
│
└── Shared/
    └── FlowLingoTypes.swift            # Models, enums, states
```

## Design System

All visual design follows `/home/team/shared/architecture/DesignSystem.md`:

- **Primary:** Indigo 600 (#4F46E5)
- **Secondary:** Emerald 500 (#10B981)
- **System Font:** San Francisco
- **Base Unit:** 4px grid
- **Corner Radius:** 12px
- **Animation:** 200ms ease-in-out
- **Haptics:** Light on keypress, medium on AI complete, error on failure

## Key Principles

### Privacy First
- Keyboard NEVER logs or transmits keystrokes passively
- Clipboard detection requires explicit opt-in
- "Full Access" is clearly explained during onboarding
- All data in transit over TLS 1.3

### Zero Clutter Design
- The FlowBar integrates seamlessly above native keyboard
- Suggestion chips appear exactly when needed
- Status indicators are subtle and auto-dismiss
- Full Dark Mode and Light Mode support

### Accessibility
- Dynamic Type throughout (UIFontMetrics)
- VoiceOver labels on every interactive element
- RTL support for Arabic/Hebrew
- Reduced motion respected

## Setup

### Prerequisites
- Xcode 15.0+
- iOS 16.0+ target
- Swift 5.9+

### Build Steps
```bash
# 1. Open the project
open FlowLingo.xcodeproj

# 2. Configure signing
# Select team and bundle identifier in target settings

# 3. Build & run
# Select the FlowLingo scheme (not the extension directly)
# Run on a physical device for keyboard testing
```

### App Groups
The keyboard extension and companion app share data via App Groups:
- Group ID: `group.com.flowlingo.shared`
- Used for: Shared preferences, cached translations, usage stats

### Keyboard Testing
1. Build the FlowLingo target on a physical device
2. Open Settings → General → Keyboard → Keyboards
3. Add FlowLingo
4. Allow Full Access when prompted
5. Open any messaging app and switch to FlowLingo keyboard

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/v1/ai/translate` | POST | Translate text with tone/context |
| `/v1/ai/analyze` | POST | Analyze slang, culture, suggest replies |
| `/v1/user/profile` | GET | Fetch user preferences |
| `/v1/user/settings` | PATCH | Update preferences |
| `/v1/billing/create-checkout` | POST | Subscription checkout |

## File Structure Reference

All iOS source files are rooted at `/home/team/shared/ios/`.
The architecture reference lives at `/home/team/shared/architecture/`.