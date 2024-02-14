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
        SimpleEntry(date: Date(), todayMinutes: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), todayMinutes: 0)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
        
        let fetchedEntities = try? persistenceController.container.viewContext.fetch(fetchRequest)
        
        var todayMinutes: Int {
            var todaySeconds = 0
            for log in fetchedEntities! {
                if Calendar.current.isDateInToday(log.timestamp!) {
                    todaySeconds += Int(log.duration)
                }
            }
            let minutes = todaySeconds / 60
//            let seconds = todaySeconds % 60
//            let formattedMinutes = String(format: "%02d:%02d", minutes, seconds)
            
            return minutes
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
    let todayMinutes: Int
}


struct CalisthenicsWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text("\(entry.todayMinutes)" + (entry.todayMinutes == 1 ? "\n minute" : "\n minutes"))
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
        CalisthenicsWidgetEntryView(entry: SimpleEntry(date: Date(), todayMinutes: 0))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
