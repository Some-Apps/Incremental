import AlertToast
import SwiftUI

struct EnableChanges: View {
    @ObservedObject private var defaultsManager = DefaultsManager()
    @Environment(\.dismiss) var dismiss
    @AppStorage("holdDuration") var holdDuration: Double = 0
    @AppStorage("lastHoldTime") var lastHoldTime: Double = Date().timeIntervalSinceReferenceDate
    @State private var isHoldingButton = false
    @State private var holdTimer: Timer?

    var body: some View {
        if holdDuration >= 300 {
            Text("You can now edit your settings")
                .font(.title)
                .multilineTextAlignment(.center)
                .onDisappear {
                    dismiss()
                }
        } else {
            VStack(spacing: 30) {
                Text("To enable changes...")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                ProgressBar(value: min(holdDuration / 300, 1.0))
                    .frame(height: 20)
                    .padding(.horizontal)

                Text("Hold Time: \(formatTime(holdDuration))")
                    .foregroundColor(.secondary)
                    .font(.body)

                Spacer()

                Text("Hold the button for 5 minutes in a single day")
                    .bold()
                    .multilineTextAlignment(.center)

                ZStack {
                    Circle()
                        .strokeBorder(isHoldingButton ? Color.green : Color.secondary, lineWidth: 4)
                        .background(Circle().fill(isHoldingButton ? Color.green.opacity(0.3) : Color.secondary.opacity(0.3)))
                        .frame(width: 100, height: 100)
                        .scaleEffect(isHoldingButton ? 1.1 : 1.0)
                        .animation(isHoldingButton ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true) : .default, value: isHoldingButton)

                    Button(action: {}) {
                        Text(isHoldingButton ? "Holding" : "Hold Me")
                            .foregroundColor(.white)
                            .font(.title2)
                            .bold()
                    }
                    .frame(width: 90, height: 90)
                    .background(isHoldingButton ? Color.green : Color.blue)
                    .clipShape(Circle())
                    .onLongPressGesture(minimumDuration: 0.01, maximumDistance: 10, pressing: { isPressing in
                        if isPressing {
                            startHolding()
                        } else {
                            stopHolding()
                        }
                    }, perform: {})
                }
            }
            .padding()
            .onDisappear {
                dismiss()
            }
        }
    }

    private func startHolding() {
        if !isHoldingButton {
            isHoldingButton = true
            if !Calendar.current.isDate(Date(timeIntervalSinceReferenceDate: lastHoldTime), inSameDayAs: Date()) {
                holdDuration = 0 // Reset if it's a new day
                defaultsManager.saveDataToiCloud(key: "holdDuration", value: holdDuration)
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
            defaultsManager.saveDataToiCloud(key: "lastHoldTime", value: lastHoldTime)
        }
    }

    private func updateHoldDuration() {
        holdDuration += 0.25
        defaultsManager.saveDataToiCloud(key: "holdDuration", value: holdDuration)
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
            }
            .cornerRadius(10)
        }
    }
}
