import GoogleMobileAds
import SwiftUI

class AdManager: NSObject, ObservableObject, GADFullScreenContentDelegate {
    @ObservedObject private var defaultsManager = DefaultsManager()

    @Published var rewardedAd: GADRewardedAd?
    @Published var rewardAmount: Double = 0
    @AppStorage("currentTab") var currentTab: Int = 0
    @AppStorage("holdDuration") var holdDuration: Double = 0
    @AppStorage("showAd") private var showAd1 = false
    @AppStorage("lastHoldTime") var lastHoldTime: Double = Date().timeIntervalSinceReferenceDate
    @AppStorage("showWatchedAd") var showWatchedAd: Bool = false


    override init() {
        super.init()
        loadRewardedAd()
    }

    func loadRewardedAd() {
//        ca-app-pub-3940256099942544/1712485313 test
//        ca-app-pub-4456875215293250/1422568668 real
        GADRewardedAd.load(withAdUnitID: "ca-app-pub-4456875215293250/1422568668", request: GADRequest()) { [weak self] ad, error in
            guard let self = self else { return }
            if let error = error {
                print("Failed to load rewarded ad with error: \(error.localizedDescription)")
                return
            }
            ad?.fullScreenContentDelegate = self
            self.rewardedAd = ad
        }
    }

    func showAd(from viewController: UIViewController) {
        if let ad = rewardedAd {
            ad.present(fromRootViewController: viewController) { [weak self] in
                guard let self = self else { return }
                // Reward the user for watching the ad
 
                
                print("User was rewarded \(self.rewardAmount)")
                
                
            }
        } else {
            print("Ad wasn't ready.")
            loadRewardedAd()
        }
    }

    // MARK: GADFullScreenContentDelegate methods
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present with error: \(error.localizedDescription)")
        loadRewardedAd() // Reload ad
    }

//    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
//        print("Ad did present full screen content.")
//    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        loadRewardedAd() // Reload ad for next time
        showAd1 = false
        self.showWatchedAd = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.holdDuration += 45
            self.lastHoldTime = Date().timeIntervalSinceReferenceDate
            self.defaultsManager.saveDataToiCloud(key: "holdDuration", value: self.holdDuration)
            self.defaultsManager.saveDataToiCloud(key: "lastHoldTime", value: self.lastHoldTime)
        }
    }
}


struct AdView: View {
    @ObservedObject var adManager: AdManager
    @Binding var showAd: Bool

    var body: some View {
        AdPresenter(adManager: adManager)
    }
}

// UIViewControllerRepresentable to bridge SwiftUI with UIKit for ad presentation
struct AdPresenter: UIViewControllerRepresentable {
    @ObservedObject var adManager: AdManager

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .clear  // Ensure the view controller is invisible
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Attempt to present the ad if available
        if let ad = adManager.rewardedAd {
            ad.present(fromRootViewController: uiViewController) {
                // Handle the reward
//                let reward = ad.adReward
//                self.adManager.rewardAmount = reward.amount.doubleValue
//                self.adManager.holdDuration += reward.amount.doubleValue
//                self.adManager.lastHoldTime = Date().timeIntervalSinceReferenceDate
                print("User was rewarded \(self.adManager.rewardAmount)")
            }
        } else {
            print("Ad wasn't ready.")
            adManager.loadRewardedAd()
        }
    }
}
