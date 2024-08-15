import Foundation
import SwiftUI

class DefaultsManager: ObservableObject {
    
    @AppStorage("randomExercise") var randomExercise: String = ""
    
    func saveDataToiCloud(key: String, value: Any) {
        let store = NSUbiquitousKeyValueStore.default
        store.set(value, forKey: key)
        store.synchronize()
    }
    func getDataFromiCloud(key: String) -> Any? {
        let store = NSUbiquitousKeyValueStore.default
        return store.object(forKey: key)
    }
    func loadSettings() {
        self.randomExercise = getDataFromiCloud(key: "randomExercise") as? String ?? ""
    }

}
