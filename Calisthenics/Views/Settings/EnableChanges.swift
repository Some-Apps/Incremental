import AlertToast
import GoogleMobileAds
import SwiftUI

struct EnableChanges: View {
    @ObservedObject private var defaultsManager = DefaultsManager()
    @AppStorage("holdDuration") var holdDuration: Double = 0
    @AppStorage("lastHoldTime") var lastHoldTime: Double = Date().timeIntervalSinceReferenceDate
    @AppStorage("showWatchedAd") var showWatchedAd: Bool = false
    @State private var isHoldingButton = false
    @State private var holdTimer: Timer?
    @StateObject var adManager = AdManager()
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("showAd") private var showAd = false


    var body: some View {
        if holdDuration >= 600 {
            Text("You can now edit your settings")
//                .font(.title)
                .multilineTextAlignment(.center)
        } else {
            VStack(spacing: 15) {
                Text("To enable changes...")
                    .font(.title)
                ProgressBar(value: min(holdDuration / 600, 1.0))
                    .frame(height: 20)
                Text("Hold Time: \(formatTime(holdDuration))")
                    .foregroundStyle(.secondary)
                    .fontWeight(.thin)
                Spacer()
                Text("Hold button for 10 minutes in a single day")
                    .bold()
                Button(isHoldingButton ? "Holding" : "Hold Me") {}
                    .buttonStyle(.bordered)
                    .tint(isHoldingButton ? .secondary : .green)
                    .onLongPressGesture(minimumDuration: 0.01, maximumDistance: 10, pressing: { isPressing in
                        if isPressing {
                            startHolding()
                        } else {
                            stopHolding()
                        }
                    }, perform: {})
                    .font(.title)
                Text("OR")
                    .fontWeight(.black)
                Text("Watch a 5-30 second ad to gain 45 seconds")
                    .bold()
                Button("Watch Ad") {
                    showAd = true
                    
                }
                .buttonStyle(.bordered)
                .tint(.green)
                .font(.title)
            }
            .toast(isPresenting: $showWatchedAd, duration: 2) {
                AlertToast(displayMode: .alert, type: .systemImage("stopwatch.fill", .green), title: "Watched Ad", subTitle: "You gained 45 seconds by watching this ad")
            }
            .padding()
            .multilineTextAlignment(.center)
            
        }
            
    }
    
    private func findPresenter() -> UIViewController? {
        // First, find the key window which is typically the window that is currently being displayed
        guard let rootViewController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return nil
        }
        
        // Check if the rootViewController is a UITabBarController
        if let tabBarController = rootViewController as? UITabBarController {
            // Access the viewController for the tab with tag 3
            let viewControllerForTag = tabBarController.viewControllers?.first { $0.tabBarItem.tag == 3 }
            // Check if there is a viewController presented on top of it
            return viewControllerForTag?.presentedViewController ?? viewControllerForTag
        }
        
        // If the rootViewController is not a UITabBarController, check if the presentedViewController is
        if let presented = rootViewController.presentedViewController as? UITabBarController {
            let viewControllerForTag = presented.viewControllers?.first { $0.tabBarItem.tag == 3 }
            return viewControllerForTag?.presentedViewController ?? viewControllerForTag
        }
        
        // If there's no UITabBarController, just return the presentedViewController or the root
        return rootViewController.presentedViewController ?? rootViewController
    }


    private func startHolding() {
        if !isHoldingButton {
            isHoldingButton = true
            if !Calendar.current.isDate(Date(timeIntervalSinceReferenceDate: lastHoldTime), inSameDayAs: Date()) {
                holdDuration = 0 // Reset if it's a new day
                defaultsManager.holdDuration = holdDuration
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
            }.cornerRadius(45.0)
        }
    }
}
