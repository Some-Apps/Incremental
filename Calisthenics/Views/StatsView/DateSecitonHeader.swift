//
//  DateSecitonHeader.swift
//  Calisthenics
//
//  Created by Jared Jones on 4/2/23.
//
import SwiftUI

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
