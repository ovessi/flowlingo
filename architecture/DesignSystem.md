# Design System Specification - FlowLingo

## 1. Brand Identity
FlowLingo represents seamless, intelligent, and borderless communication. The design should feel "invisible" (integrating with native OS) yet powerful.

## 2. Design Tokens

### 2.1 Color Palette
*   **Primary (Action):** `#4F46E5` (Indigo 600)
*   **Secondary:** `#10B981` (Emerald 500)
*   **Success:** `#22C55E`
*   **Error:** `#EF4444`
*   **Neutral (Light Mode):**
    *   Background: `#FFFFFF`
    *   Surface: `#F3F4F6`
    *   Text High: `#111827`
    *   Text Low: `#6B7280`
*   **Neutral (Dark Mode):**
    *   Background: `#111827`
    *   Surface: `#1F2937`
    *   Text High: `#F9FAFB`
    *   Text Low: `#9CA3AF`

### 2.2 Typography
*   **System Fonts:**
    *   iOS: San Francisco
    *   Android: Roboto
*   **Scale:**
    *   `Display`: 32px / Bold
    *   `Heading`: 20px / Semibold
    *   `Body`: 16px / Regular
    *   `Caption`: 12px / Medium

### 2.3 Spacing & Grid
*   **Base Unit:** 4px
*   **Padding:** 16px (Standard mobile gutter)
*   **Radius:** 12px (Standard for cards and buttons)

## 3. Keyboard Component Library

### 3.1 The Action Bar (The "FlowBar")
*   Floating bar above the keyboard keys.
*   Contains:
    *   Language Selector (Source -> Target)
    *   Tone Toggle (Icon-based)
    *   "Analyze" Sparkle Icon
    *   Settings Gear

### 3.2 Suggestion Chips
*   Horizontally scrolling chips for AI-suggested replies.
*   Interaction: Tap to insert, Long-press to preview translation.

### 3.3 Status Indicators
*   Subtle pulsing dot (Indigo) when AI is "thinking."
*   Offline banner when translation packs are missing.

## 4. Accessibility (WCAG 2.1 AA)
*   **Contrast:** Minimum 4.5:1 for all text.
*   **Dynamic Type:** Keyboard UI must scale according to OS text size settings.
*   **Haptics:** Light vibration on successful AI insertion; double-tap haptic for errors.
*   **RTL Support:** Full mirroring for Arabic/Hebrew scripts.

## 5. Animation Specs
*   **Transition:** 200ms Ease-in-out for bar expansion.
*   **Sparkle Effect:** Subtle CSS/Lottie animation when text is analyzed.
