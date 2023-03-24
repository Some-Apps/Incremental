//
//  SettingsView.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/22/23.
//

import SwiftUI

struct SettingsView: View {
    let moc = PersistenceController.shared.container.viewContext
    @FetchRequest(sortDescriptors: []) var logs: FetchedResults<Log>
    
    var todayMinutes: Double {
        let numberOfDecimalPlaces = 2
        let multiplier = pow(10.0, Double(numberOfDecimalPlaces))

        var todaySeconds = 0
        for log in logs {
            if Calendar.current.isDateInToday(log.timestamp!) {
                todaySeconds += Int(log.duration)
            }
        }
        return ((Double(todaySeconds)/60.0) * multiplier).rounded() / multiplier
    }
    
    var body: some View {
        VStack {
            Text(String(todayMinutes))
            List {
                ForEach(logs, id:\.id) { log in
                    HStack {
                        Text(log.exercise!)
                        Spacer()
                        Text("\(log.duration)")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
