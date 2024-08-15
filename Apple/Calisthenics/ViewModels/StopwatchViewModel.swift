import Combine
import SwiftUI

class StopwatchViewModel: ObservableObject {
    static let shared = StopwatchViewModel()
    
    @Published var seconds: Int = 0
    @Published var isRunning: Bool = false

    private var timer: Timer?

    func startStop() {
        if isRunning {
            timer?.invalidate()
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
                self?.seconds += 1
            })
        }
        isRunning.toggle()
    }

    func reset() {
        seconds = 0
    }
}
