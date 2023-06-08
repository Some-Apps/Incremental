//
//  Stopwatch.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/24/23.
//

import SwiftUI

struct StopwatchView: View {
    @ObservedObject var viewModel = StopwatchViewModel.shared

    var seconds: String {
        String(format: "%02d", viewModel.seconds % 60)
    }

    var hours: String {
        String(format: "%02d", viewModel.seconds / 3600)
    }

    var minutes: String {
        String(format: "%02d", (viewModel.seconds % 3600) / 60)
    }

    var body: some View {
        VStack {
            HStack {
                Text("\(minutes) : \(seconds)")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
            }
            HStack {
                Button(viewModel.isRunning ? "Stop" : "Start") {
                    viewModel.startStop()
                }
                .tint(viewModel.isRunning ? .red : .green)
                .font(.largeTitle)
                .buttonStyle(.bordered)
                Button("Reset") {
                    viewModel.reset()
                }
                .tint(.gray)
                .font(.largeTitle)
                .buttonStyle(.bordered)
            }
            .padding(.top, 10)
            .preventSleep(isRunning: $viewModel.isRunning)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15.0)
        .shadow(radius: 3)
    }
}


extension String {
    func substring(index: Int) -> String {
        let arrayString = Array(self)
        return String(arrayString[index])
    }
}
