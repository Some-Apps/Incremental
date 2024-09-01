//
//  TutorialView.swift
//  Calisthenics
//
//  Created by Jared Jones on 5/12/24.
//

import SwiftUI

struct TutorialView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 50) {
                TutorialItem(title: "Overview", description: "This app randomly suggests your next exercise based on the exercises you add and how difficult they are for you to complete. It will automatically increment and decrement reps or duration based on your previous attemps. It tracks the amount of time it takes to complete each evercise and how difficult it was. Read the sections below to learn how to use each tab.")
                TutorialItem(title: "Exercise Tab", description: "At the top of the screen is the amount of time you've spent exercising today. Below that is the next exercise for you to complete. If you are unable to do that exercise right now and would like to skip it, tap \"Stash Exercise\". When you start exercising, tap \"Start\" on the timer and tap \"Stop\" once you\'re done. If you\'d like to give yourself a 5 second countdown before starting the timer, tap the button to the left of \"Start\". After tapping \"Stop\", you will be able to select how difficult it was and tap \"Finish\". A new random exercise will then appear.")
                TutorialItem(title: "Stashed Tab", description: "This is where exercises go when you tap \"Stash Exercise\". You can complete them just as you would in the \"Exercise\" tab. You can have a maximum of 10 stashed exercises at a time.")
                TutorialItem(title: "Repertoire Tab", description: "Here you can add and remove exercises and view more info about the exercise by tapping on them.")
                TutorialItem(title: "Settings Tab", description: "Here you can view this tutorial, a history of the exercises you've completed, and view other options.")
                TutorialItem(title: "Widget", description: "This app has a widget that allows your to see how many minutes you've spent exercising today.")
            }
            .padding()
        }
    }
}

struct TutorialItem: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            Divider()
            Text(description)
        }

    }
}

#Preview {
    TutorialView()
}
