//
//  SettingsView.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/22/23.
//

import SwiftUI

struct StatsView: View {
    let moc = PersistenceController.shared.container.viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: false)]) var logs: FetchedResults<Log>
    @Environment(\.editMode) private var editMode
    
    @State private var expandedSections: [Date] = []
    
    var today: Date {
        Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
    }

    var groupedLogs: [Date: [Log]] {
        Dictionary(grouping: logs) { dateWithoutTime(from: $0.timestamp!) }
    }
    
    var sortedDates: [Date] {
        groupedLogs.keys.sorted(by: { $0 > $1 })
    }

    func dateWithoutTime(from date: Date) -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return Calendar.current.date(from: components)!
    }

    func dateString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }

    var body: some View {
        VStack {
            List {
                ForEach(sortedDates, id: \.self) { date in
                    Section(header: HStack {
                        Text(dateString(from: date))
                            .font(.headline)
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
                    }) {
                        if expandedSections.contains(date) {
                            ForEach(groupedLogs[date]!, id: \.id) { log in
                                HStack {
                                    Text(log.exercise!)
                                    Spacer()
                                    Text("\(log.duration)")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .onDelete(perform: { offsets in
                                deleteTasks(offsets: offsets, date: date)
                            })
                        }
                    }
                }
            }
        }
        .onAppear {
            if let todayLogs = groupedLogs[today] {
                expandedSections = [today]
            }
        }
    }

    private func deleteTasks(offsets: IndexSet, date: Date) {
        withAnimation {
            let logsToDelete = groupedLogs[date]!
            offsets.map { logsToDelete[$0] }.forEach(moc.delete)
            try? moc.save()
        }
    }
}



struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
    }
}
