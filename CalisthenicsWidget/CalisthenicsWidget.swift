import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    @Environment(\.modelContext) private var modelContext
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []


        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}


struct CalisthenicsWidgetEntryView : View {
    @Query var logs: [Log]
    @AppStorage("widgetTimeframe", store: UserDefaults(suiteName: "group.me.jareddanieljones.calisthenics")) var widgetTimeframe: String = "Day"
    var entry: Provider.Entry

    func totalDurationText() -> (duration: String, label: String) {
        let (duration, timeframeLabel) = totalDurationForSelectedTimeframe(logs: logs)
        return (duration + " minutes", timeframeLabel)
    }
    
    func totalDurationForSelectedTimeframe(logs: [Log]) -> (String, String) {
        let calendar = Calendar.autoupdatingCurrent
        let now = Date()
        var filteredLogs: [Log] = []
        var timeframeLabel = "today"

        switch widgetTimeframe {
        case "Day":
            filteredLogs = logs.filter { calendar.isDateInToday($0.timestamp!) }
            timeframeLabel = "today"
        case "Week":
            filteredLogs = logs.filter { calendar.isDate($0.timestamp!, equalTo: now, toGranularity: .weekOfYear) }
            timeframeLabel = "this week"
        case "Month":
            filteredLogs = logs.filter { calendar.isDate($0.timestamp!, equalTo: now, toGranularity: .month) }
            timeframeLabel = "this month"
        default:
            filteredLogs = logs.filter { calendar.isDateInToday($0.timestamp!) }
        }

        let totalDuration = filteredLogs.reduce(0) { $0 + TimeInterval($1.duration!) }
        let minutes = Int(totalDuration) / 60
        let seconds = Int(totalDuration) % 60

        // Return both a time string and the timeframe label
        return ("\(minutes)", timeframeLabel)
//        return (String(format: "%02d:%02d", minutes, seconds), timeframeLabel)
    }
    
    
    
    var body: some View {
        let result = totalDurationText()
        VStack {
            Spacer()
            Text(result.duration)
                .font(.title)
                .fontWeight(.bold)
            Spacer()
            Text(result.label)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
        .containerBackground(.clear, for: .widget)
    }
}

struct CalisthenicsWidget: Widget {
    let kind: String = "CalisthenicsWidget"
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Log.self,
            Exercise.self,
            StashedExercise.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .automatic)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CalisthenicsWidgetEntryView(entry: entry)
                .modelContainer(sharedModelContainer)
        }
        .configurationDisplayName("Calisthenics")
        .description("Minutes exercised today")
        .supportedFamilies([.systemSmall])
    }
}

struct CalisthenicsWidget_Previews: PreviewProvider {
    static var previews: some View {
        CalisthenicsWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
