//
//  LogRow.swift
//  Calisthenics
//
//  Created by Jared Jones on 4/2/23.
//
import SwiftUI

struct LogRow: View {
    let aggregatedLog: AggregatedLog

    var body: some View {
        HStack {
            Text(aggregatedLog.exercise)
            Spacer()
            Text(formattedReps(aggregatedLog))
                .foregroundColor(.secondary)
        }
    }
    
    func formattedReps(_ log: AggregatedLog) -> String {
        if log.units == "Duration" {
            let minutes = log.reps / 60
            let seconds = log.reps % 60
            return String(format: "%01d:%02d", minutes, seconds)
        } else {
            return String(log.reps)
        }
    }
}
