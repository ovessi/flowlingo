import WidgetKit
import SwiftUI
import UIKit

// MARK: - FlowLingo Today Widget

/// Simple widget showing quick stats: actions today, quick language toggle.
/// Available in small and medium sizes on the iOS Home Screen / Today View.
struct FlowLingoWidget: Widget {
    let kind: String = "com.flowlingo.widget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            FlowLingoWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("FlowLingo")
        .description("Quick stats and language toggle.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Timeline Entry

struct FlowLingoEntry: TimelineEntry {
    let date: Date
    let todayActions: Int
    let sourceLanguage: String
    let targetLanguage: String
    let isPremium: Bool
}

// MARK: - Provider

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> FlowLingoEntry {
        FlowLingoEntry(
            date: Date(),
            todayActions: 12,
            sourceLanguage: "EN",
            targetLanguage: "ES",
            isPremium: false
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (FlowLingoEntry) -> Void) {
        let entry = FlowLingoEntry(
            date: Date(),
            todayActions: loadTodayActions(),
            sourceLanguage: loadSourceLanguage(),
            targetLanguage: loadTargetLanguage(),
            isPremium: loadIsPremium()
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<FlowLingoEntry>) -> Void) {
        let entry = FlowLingoEntry(
            date: Date(),
            todayActions: loadTodayActions(),
            sourceLanguage: loadSourceLanguage(),
            targetLanguage: loadTargetLanguage(),
            isPremium: loadIsPremium()
        )
        
        // Refresh every hour
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600)))
        completion(timeline)
    }
    
    // MARK: - Data Loading
    
    private func loadTodayActions() -> Int {
        UserDefaults.standard.integer(forKey: "today_actions")
    }
    
    private func loadSourceLanguage() -> String {
        guard let data = UserDefaults.standard.data(forKey: "user_preferences"),
              let prefs = try? JSONDecoder().decode(UserPreferences.self, from: data) else {
            return "EN"
        }
        return prefs.nativeLanguage.uppercased()
    }
    
    private func loadTargetLanguage() -> String {
        guard let data = UserDefaults.standard.data(forKey: "user_preferences"),
              let prefs = try? JSONDecoder().decode(UserPreferences.self, from: data) else {
            return "ES"
        }
        return prefs.targetLanguage.uppercased()
    }
    
    private func loadIsPremium() -> Bool {
        UserDefaults.standard.string(forKey: "subscription_tier") == "premium"
    }
}

// MARK: - Widget View

struct FlowLingoWidgetEntryView: View {
    var entry: FlowLingoEntry
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        default:
            mediumWidget
        }
    }
    
    private var smallWidget: View {
        VStack(spacing: 12) {
            // Logo area
            HStack(spacing: 6) {
                Image(systemName: "sparkle.magnifyingglass")
                    .font(.caption)
                    .foregroundColor(.indigo)
                Text("FlowLingo")
                    .font(.caption.weight(.semibold))
            }
            
            Divider()
            
            // Language pair
            HStack(spacing: 4) {
                Text(entry.sourceLanguage)
                    .font(.title3.weight(.bold))
                Image(systemName: "arrow.right")
                    .font(.caption2)
                    .foregroundColor(.indigo)
                Text(entry.targetLanguage)
                    .font(.title3.weight(.bold))
            }
            
            // Actions count
            VStack(spacing: 0) {
                Text("\(entry.todayActions)")
                    .font(.title.weight(.bold))
                    .foregroundColor(.indigo)
                Text("today")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
    
    private var mediumWidget: some View {
        HStack(spacing: 16) {
            // Left side: Language pair
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkle.magnifyingglass")
                        .font(.caption)
                        .foregroundColor(.indigo)
                    Text("FlowLingo")
                        .font(.caption.weight(.semibold))
                }
                
                HStack(spacing: 4) {
                    Text(entry.sourceLanguage)
                        .font(.title2.weight(.bold))
                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .foregroundColor(.indigo)
                    Text(entry.targetLanguage)
                        .font(.title2.weight(.bold))
                }
                
                if entry.isPremium {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                        Text("Premium")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Right side: Stats
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(entry.todayActions)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.indigo)
                Text("actions today")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Image(systemName: "arrow.up.forward")
                    .font(.body)
                    .foregroundColor(.indigo.opacity(0.5))
            }
        }
        .padding()
    }
}

// MARK: - Widget Registration

#Preview(as: .systemSmall) {
    FlowLingoWidget()
} timeline: {
    FlowLingoEntry(
        date: Date(),
        todayActions: 42,
        sourceLanguage: "EN",
        targetLanguage: "ES",
        isPremium: true
    )
}

#Preview(as: .systemMedium) {
    FlowLingoWidget()
} timeline: {
    FlowLingoEntry(
        date: Date(),
        todayActions: 42,
        sourceLanguage: "EN",
        targetLanguage: "ES",
        isPremium: true
    )
}