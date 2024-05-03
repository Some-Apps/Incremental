//
//  EnableChangesViewModel.swift
//  Calisthenics
//
//  Created by Jared Jones on 5/3/24.
//

import GoogleMobileAds
import UIKit

class AdManager: NSObject, GADFullScreenContentDelegate {
    static let shared = AdManager()
    var rewardedAd: GADRewardedAd?

    override init() {
        super.init()
        loadRewardedAd()
    }

    func loadRewardedAd() {
        GADRewardedAd.load(withAdUnitID: "ca-app-pub-3940256099942544/1712485313", request: GADRequest()) { [weak self] ad, error in
            if let error = error {
                print("Failed to load rewarded ad with error: \(error.localizedDescription)")
                return
            }
            self?.rewardedAd = ad
            self?.rewardedAd?.fullScreenContentDelegate = self
        }
    }

    func showRewardedAd(from viewController: UIViewController) {
        if let ad = rewardedAd {
            ad.present(fromRootViewController: viewController) {
                // Reward the user for watching the ad
                let rewardAmount = ad.adReward.amount.doubleValue
                print("User was rewarded \(rewardAmount)")
                // You should handle the reward update here.
            }
        } else {
            print("Ad wasn't ready.")
            // It might be good to try reloading the ad here.
            loadRewardedAd()
        }
    }

    // MARK: - GADFullScreenContentDelegate methods
//    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
//        print("Ad did present full screen content.")
//    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present with error: \(error.localizedDescription)")
        // Consider reloading the ad here
        loadRewardedAd()
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad was dismissed.")
        // Reloading the ad for the next possible show
        loadRewardedAd()
    }
}

