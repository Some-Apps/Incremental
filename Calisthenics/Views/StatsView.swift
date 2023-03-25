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

    
    var todayMinutes: String {

        var todaySeconds = 0
        for log in logs {
            if Calendar.current.isDateInToday(log.timestamp!) {
                todaySeconds += Int(log.duration)
            }
        }
        let minutes = todaySeconds / 60
            let seconds = todaySeconds % 60
            let formatedMinutes = String(format: "%01d:%02d", minutes, seconds)
        
        return formatedMinutes
    }
    
    var body: some View {
        VStack {
            Text(todayMinutes)
//            ScrollView {
                List {
                    ForEach(logs, id:\.id) { log in
                        HStack {
                            Text(log.exercise!)
                            Spacer()
                            Text("\(log.duration)")
                                .foregroundColor(.secondary)
                        }
                    }
                    .onDelete(perform: deleteTasks)
                }
//            }
            
        }
    }
    
    private func deleteTasks(offsets: IndexSet) {
            withAnimation {
                offsets.map { logs[$0] }.forEach(moc.delete)
                try? moc.save()
            }
        }
    
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
    }
}
