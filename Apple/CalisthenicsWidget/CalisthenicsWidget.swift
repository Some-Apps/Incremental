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

    func totalDurationToday() -> String {
        print(logs)
        let newLogs = logs.filter( { Calendar.autoupdatingCurrent.isDateInToday($0.timestamp!) } )
        
        let totalDuration = newLogs.reduce(0) { $0 + TimeInterval($1.duration!) }
        let minutes = Int(totalDuration) / 60
        let seconds = Int(totalDuration) % 60
        return "\(minutes) \(minutes == 1 ? "minute" : "minutes")"
    }
    var entry: Provider.Entry

    var body: some View {
        Text(totalDurationToday())
            .fontWeight(.bold)
            .font(.title)
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
