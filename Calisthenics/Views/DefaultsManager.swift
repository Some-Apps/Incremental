//
//  DefaultsManager.swift
//  Calisthenics
//
//  Created by Jared Jones on 5/4/24.
//

import Foundation

class DefaultsManager: ObservableObject {
    func saveDataToiCloud(key: String, value: Any) {
        let store = NSUbiquitousKeyValueStore.default
        store.set(value, forKey: key)
        store.synchronize()  // Ensuring data is synced, though this is typically unnecessary as sync happens automatically
    }
    func getDataFromiCloud(key: String) -> Any? {
        let store = NSUbiquitousKeyValueStore.default
        return store.object(forKey: key)
    }

}
