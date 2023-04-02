//
//  SettingsView.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/22/23.
//

import Charts
import SwiftUI

struct StatsView: View {
    let moc = PersistenceController.shared.container.viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: false)]) var logs: FetchedResults<Log>
    @Environment(\.editMode) private var editMode
    @State private var expandedSections: [Date] = []
    var today: Date {
        Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
    }
    // Updated groupedLogs to further group by exercise
    var groupedLogs: [Date: (totalDuration: Int, logs: [AggregatedLog])] {
        let dateGroupedLogs = Dictionary(grouping: logs) { dateWithoutTime(from: $0.timestamp!) }

        return dateGroupedLogs.mapValues { logs in
            let totalDuration = logs.reduce(0) { $0 + Int($1.duration) }
            
            let exerciseGroupedLogs = Dictionary(grouping: logs, by: { $0.exercise! })

            let combinedLogs = exerciseGroupedLogs.map { (exercise, logs) -> AggregatedLog in
                let combinedReps = logs.reduce(0) { $0 + Int($1.reps) }
                let units = logs.first?.units ?? "Reps"
                return AggregatedLog(id: UUID(), exercise: exercise, reps: Int64(combinedReps), duration: Int64(combinedReps), timestamp: logs.first?.timestamp, units: units)
            }.sorted(by: { $0.exercise < $1.exercise }) // Sort exercises alphabetically

            
            return (totalDuration, combinedLogs)
        }
    }

    var sortedDates: [Date] {
        groupedLogs.keys.sorted(by: { $0 > $1 })
    }
    
    func dateWithoutTime(from date: Date) -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return Calendar.current.date(from: components)!
    }
    
    func durationString(from duration: Int) -> String {
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        VStack {
            // ADD CHART HERE
            List {
                ForEach(sortedDates, id: \.self) { date in
                    let totalDuration = groupedLogs[date]?.totalDuration ?? 0
                    let durationText = durationString(from: totalDuration)
                    Section(header: DateSectionHeader(date: date, totalDuration: TimeInterval(totalDuration), expandedSections: $expandedSections)) {
                        if expandedSections.contains(date) {
                            ForEach(groupedLogs[date]?.logs ?? [], id: \.id) { log in
                                LogRow(aggregatedLog: log)
                            }
                            .onDelete(perform: { offsets in
                                deleteTasks(offsets: offsets, date: date)
                            })
                        }
                    }
                }
            }
        }
    }
    
    private func deleteTasks(offsets: IndexSet, date: Date) {
        withAnimation {
            let dateLogs = groupedLogs[date]?.logs ?? []

            offsets.forEach { index in
                let aggregatedLog = dateLogs[index]
                let logsToDelete = logs.filter { $0.timestamp == aggregatedLog.timestamp && $0.exercise == aggregatedLog.exercise }
                
                logsToDelete.forEach { log in
                    moc.delete(log)
                }
            }

            try? moc.save()
        }
    }

}

struct AggregatedLog {
    let id: UUID
    let exercise: String
    let reps: Int64
    let duration: Int64
    let timestamp: Date?
    let units: String
}
