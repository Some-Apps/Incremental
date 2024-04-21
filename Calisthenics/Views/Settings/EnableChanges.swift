//
//  EnableChanges.swift
//  Calisthenics
//
//  Created by Jared Jones on 4/21/24.
//

import SwiftUI

struct EnableChanges: View {
    @AppStorage("budget") var budget: Double = 10
    @AppStorage("holdDuration") var holdDuration: Double = 0
    @AppStorage("lastHoldTime") var lastHoldTime: Double = Date().timeIntervalSinceReferenceDate

    @State private var isHoldingButton = false
    @State private var holdTimer: Timer?

    var body: some View {
        if holdDuration >= 60 {
            Text("You can now edit your settings")
                .font(.title)
                .multilineTextAlignment(.center)
        } else {
            VStack(spacing: 15) {
                Text("Hold button for 10 minutes in a single day to enable changes")
                    .bold()
                ProgressBar(value: min(holdDuration / 60, 1.0)) // Progress bar for 20 minutes
                    .frame(height: 20)
                Text("Hold time: \(formatTime(holdDuration))")
                Button(isHoldingButton ? "Holding" : "Hold to Enable") {}
                    .buttonStyle(.bordered)
                    .tint(isHoldingButton ? .secondary : .green)
                    .onLongPressGesture(minimumDuration: 0.01, maximumDistance: 10, pressing: { isPressing in
                        if isPressing {
                            startHolding()
                        } else {
                            stopHolding()
                        }
                    }, perform: {})
                    .font(.largeTitle)
            }
            .padding()
            .multilineTextAlignment(.center)

        }
    }

    private func startHolding() {
        if !isHoldingButton {
            isHoldingButton = true
            if !Calendar.current.isDate(Date(timeIntervalSinceReferenceDate: lastHoldTime), inSameDayAs: Date()) {
                holdDuration = 0 // Reset if it's a new day
            }
            holdTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
                self.updateHoldDuration()
            }
        }
    }

    private func stopHolding() {
        if isHoldingButton {
            isHoldingButton = false
            holdTimer?.invalidate()
            holdTimer = nil
            lastHoldTime = Date().timeIntervalSinceReferenceDate // Update last hold time
        }
    }

    private func updateHoldDuration() {
        holdDuration += 0.25
    }

    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return "\(minutes)m \(seconds)s"
    }
}

struct ProgressBar: View {
    var value: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color.gray)
                
                Rectangle().frame(width: min(CGFloat(value) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color.blue)
                    .animation(.linear, value: value)
            }.cornerRadius(45.0)
        }
    }
}
