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
                        
//        @Query var logs: [Log]
        
//        var todayMinutes: Int {
//            var todaySeconds = 0
//            for log in logs {
//                if Calendar.current.isDateInToday(log.timestamp) {
//                    todaySeconds += Int(log.duration)
//                }
//            }
//            let minutes = todaySeconds / 60
//            return minutes
//        }


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
    var entry: Provider.Entry

    var body: some View {
        Text("Coming Soon")
            .fontWeight(.bold)
            .font(.title)
            .multilineTextAlignment(.center)
            .containerBackground(.clear, for: .widget)
    }
}

struct CalisthenicsWidget: Widget {
    let kind: String = "CalisthenicsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CalisthenicsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("some Calisthenics")
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
