//
//  CalisthenicsWidget.swift
//  CalisthenicsWidget
//
//  Created by Jared Jones on 3/25/23.
//

import CoreData
import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    let persistenceController = PersistenceController.shared
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), todayMinutes: "00:00")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), todayMinutes: "00:00")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
        
        let fetchedEntities = try? persistenceController.container.viewContext.fetch(fetchRequest)
        
        var todayMinutes: String {

            var todaySeconds = 0
            for log in fetchedEntities! {
                if Calendar.current.isDateInToday(log.timestamp!) {
                    todaySeconds += Int(log.duration)
                }
            }
            let minutes = todaySeconds / 60
//            let seconds = todaySeconds % 60
//            let formatedMinutes = String(format: "%02d:%02d", minutes, seconds)
            
            return String(minutes)
        }

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, todayMinutes: todayMinutes)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let todayMinutes: String
}

struct CalisthenicsWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(.green.gradient)
            Text(Int(entry.todayMinutes)! != 1 ? "\(entry.todayMinutes)\n minutes" : "\(entry.todayMinutes)\n minute")
                .bold()
                .font(.title)
                .multilineTextAlignment(.center)
        }
    }
}

struct CalisthenicsWidget: Widget {
    let kind: String = "CalisthenicsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CalisthenicsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct CalisthenicsWidget_Previews: PreviewProvider {
    static var previews: some View {
        CalisthenicsWidgetEntryView(entry: SimpleEntry(date: Date(), todayMinutes: "00:00"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
