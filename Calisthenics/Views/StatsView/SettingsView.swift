//
//  SettingsView.swift
//  Calisthenics
//
//  Created by Jared Jones on 6/5/23.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("easyPercent") var easyPercent = 110
    @AppStorage("mediumPercent") var mediumPercent = 105
    @AppStorage("hardPercent") var hardPercent = 95

    
    var body: some View {
        Form {
            Stepper("Easy: \(easyPercent)%", value: $easyPercent, step: 1)
            Stepper("Medium: \(mediumPercent)%", value: $mediumPercent, step: 1)
            Stepper("Hard: \(hardPercent)%", value: $hardPercent, step: 1)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
