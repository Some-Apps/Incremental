//
//  Stopwatch.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/24/23.
//

import SwiftUI

struct StopwatchView: View {
    @ObservedObject var viewModel: StopwatchViewModel

    var seconds: Int {
        viewModel.seconds % 60
    }

    var hours: Int {
        viewModel.seconds / 3600
    }

    var minutes: Int {
        (viewModel.seconds % 3600) / 60
    }

    var body: some View {
        VStack {
            HStack {
                Text("\(minutes) : \(seconds)")
                    .font(.title)
                    .fontWeight(.heavy)
            }
            HStack {
                Button(viewModel.isRunning ? "Stop" : "Start") {
                    viewModel.startStop()
                }
                .buttonStyle(.bordered)
                Button("Reset") {
                    viewModel.reset()
                }
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
