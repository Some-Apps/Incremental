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
    
    var groupedLogs: [Date: (totalDuration: Int, logs: [Log])] {
        Dictionary(grouping: logs) { dateWithoutTime(from: $0.timestamp!) }
            .mapValues { logs in
                let totalDuration = logs.reduce(0) { $0 + Int($1.duration) }
                return (totalDuration, logs)
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
                                LogRow(log: log)
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
            let logsToDelete = groupedLogs[date]?.logs ?? []
            offsets.map { logsToDelete[$0] }.forEach(moc.delete)
            try? moc.save()
        }
    }
}

struct DateSectionHeader: View {
    let date: Date
    let totalDuration: TimeInterval
    @Binding var expandedSections: [Date]

    var body: some View {
        HStack {
            Text(dateString(from: date))
                .font(.headline)
            Text(durationString(from: Int(totalDuration)))
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Image(systemName: expandedSections.contains(date) ? "chevron.down" : "chevron.right")
                .foregroundColor(.gray)
                .onTapGesture {
                    withAnimation {
                        if expandedSections.contains(date) {
                            expandedSections.removeAll { $0 == date }
                        } else {
                            expandedSections.append(date)
                        }
                    }
                }
        }
    }
    
    func dateString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
    
    
    func durationString(from duration: Int) -> String {
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct LogRow: View {
    let log: Log

    var body: some View {
        HStack {
            Text(log.exercise!)
            Spacer()
            Text(String(log.reps))
                .foregroundColor(.secondary)
        }
    }
    
    func durationString(from duration: Int) -> String {
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
