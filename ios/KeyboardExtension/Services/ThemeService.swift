import UIKit

// MARK: - Theme Service

/// Manages light/dark mode appearance for the keyboard extension.
/// Uses system color traits and custom design tokens from FlowLingo's Design System.
final class ThemeService {
    
    // MARK: - Design Tokens
    
    enum Colors {
        // Primary
        static let primary = UIColor(red: 0.310, green: 0.275, blue: 0.898, alpha: 1.0) // #4F46E5 Indigo 600
        static let primaryLight = UIColor(red: 0.541, green: 0.502, blue: 0.937, alpha: 1.0) // Indigo 400
        static let primaryDark = UIColor(red: 0.192, green: 0.161, blue: 0.678, alpha: 1.0) // Indigo 800
        
        // Secondary
        static let secondary = UIColor(red: 0.067, green: 0.725, blue: 0.506, alpha: 1.0) // #10B981 Emerald 500
        static let secondaryLight = UIColor(red: 0.341, green: 0.875, blue: 0.686, alpha: 1.0) // Emerald 300
        
        // Status
        static let success = UIColor(red: 0.133, green: 0.773, blue: 0.369, alpha: 1.0) // #22C55E
        static let error = UIColor(red: 0.937, green: 0.267, blue: 0.267, alpha: 1.0) // #EF4444
        static let warning = UIColor(red: 0.953, green: 0.612, blue: 0.071, alpha: 1.0) // #F59E0B
        
        // Light Mode Neutrals
        struct Light {
            static let background = UIColor(white: 1.0, alpha: 1.0)          // #FFFFFF
            static let surface = UIColor(white: 0.953, alpha: 1.0)           // #F3F4F6
            static let textHigh = UIColor(white: 0.067, alpha: 1.0)          // #111827
            static let textMid = UIColor(white: 0.290, alpha: 1.0)           // #4B5563
            static let textLow = UIColor(white: 0.420, alpha: 1.0)           // #6B7280
            static let border = UIColor(white: 0.898, alpha: 1.0)            // #E5E7EB
            static let separator = UIColor(white: 0.867, alpha: 1.0)         // #DDDDDD
        }
        
        // Dark Mode Neutrals
        struct Dark {
            static let background = UIColor(red: 0.067, green: 0.094, blue: 0.153, alpha: 1.0)   // #111827
            static let surface = UIColor(red: 0.122, green: 0.161, blue: 0.216, alpha: 1.0)      // #1F2937
            static let textHigh = UIColor(white: 0.976, alpha: 1.0)                               // #F9FAFB
            static let textMid = UIColor(white: 0.851, alpha: 1.0)                                // #D1D5DB
            static let textLow = UIColor(white: 0.612, alpha: 1.0)                                // #9CA3AF
            static let border = UIColor(red: 0.243, green: 0.290, blue: 0.357, alpha: 1.0)       // #3E4A5C
            static let separator = UIColor(red: 0.180, green: 0.220, blue: 0.280, alpha: 1.0)    // #2E3846
        }
        
        // FlowBar specific
        static let flowBarBackground = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? Dark.surface : Light.surface
        }
        
        static let flowBarTint = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? primaryLight : primary
        }
    }
    
    // MARK: - Typography
    
    enum Typography {
        static let display = UIFont.systemFont(ofSize: 32, weight: .bold)
        static let heading = UIFont.systemFont(ofSize: 20, weight: .semibold)
        static let body = UIFont.systemFont(ofSize: 16, weight: .regular)
        static let caption = UIFont.systemFont(ofSize: 12, weight: .medium)
        
        static func scaledDisplay(for traitCollection: UITraitCollection) -> UIFont {
            UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: display)
        }
        
        static func scaledHeading(for traitCollection: UITraitCollection) -> UIFont {
            UIFontMetrics(forTextStyle: .title2).scaledFont(for: heading)
        }
        
        static func scaledBody(for traitCollection: UITraitCollection) -> UIFont {
            UIFontMetrics(forTextStyle: .body).scaledFont(for: body, maximumPointSize: 22)
        }
        
        static func scaledCaption(for traitCollection: UITraitCollection) -> UIFont {
            UIFontMetrics(forTextStyle: .caption1).scaledFont(for: caption)
        }
    }
    
    // MARK: - Layout Constants
    
    enum Layout {
        static let baseUnit: CGFloat = 4
        static let padding: CGFloat = 16
        static let radius: CGFloat = 12
        static let smallRadius: CGFloat = 8
        static let chipHeight: CGFloat = 36
        static let flowBarHeight: CGFloat = 44
        static let buttonSize: CGFloat = 36
        static let iconSize: CGFloat = 20
        static let separatorHeight: CGFloat = 0.5
    }
    
    // MARK: - Current Theme Resolution
    
    static func currentBackground(for traitCollection: UITraitCollection) -> UIColor {
        traitCollection.userInterfaceStyle == .dark ? Colors.Dark.background : Colors.Light.background
    }
    
    static func currentSurface(for traitCollection: UITraitCollection) -> UIColor {
        traitCollection.userInterfaceStyle == .dark ? Colors.Dark.surface : Colors.Light.surface
    }
    
    static func currentTextHigh(for traitCollection: UITraitCollection) -> UIColor {
        traitCollection.userInterfaceStyle == .dark ? Colors.Dark.textHigh : Colors.Light.textHigh
    }
    
    static func currentTextMid(for traitCollection: UITraitCollection) -> UIColor {
        traitCollection.userInterfaceStyle == .dark ? Colors.Dark.textMid : Colors.Light.textMid
    }
    
    static func currentTextLow(for traitCollection: UITraitCollection) -> UIColor {
        traitCollection.userInterfaceStyle == .dark ? Colors.Dark.textLow : Colors.Light.textLow
    }
    
    static func currentBorder(for traitCollection: UITraitCollection) -> UIColor {
        traitCollection.userInterfaceStyle == .dark ? Colors.Dark.border : Colors.Light.border
    }
    
    static func currentSeparator(for traitCollection: UITraitCollection) -> UIColor {
        traitCollection.userInterfaceStyle == .dark ? Colors.Dark.separator : Colors.Light.separator
    }
}