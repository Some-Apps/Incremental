import SwiftUI
import UIKit

struct PreventSleep: ViewModifier {
    @Binding var isRunning: Bool

    func body(content: Content) -> some View {
        content
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = isRunning
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
            .onChange(of: isRunning) {
                UIApplication.shared.isIdleTimerDisabled = isRunning
            }
    }
}

extension View {
    func preventSleep(isRunning: Binding<Bool>) -> some View {
        self.modifier(PreventSleep(isRunning: isRunning))
    }
}
