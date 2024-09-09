//
//  Stopwatch.swift
//  Calisthenics
//
//  Created by Jared Jones on 3/24/23.
//

import SwiftUI

struct StopwatchView: View {
    @EnvironmentObject var colorScheme: ColorSchemeState

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
            if viewModel.seconds >= 0 {
                Text("\(minutes) : \(seconds)")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundStyle(colorScheme.current.primaryText)

            } else {
                Text(seconds.replacingOccurrences(of: "-", with: ""))
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundStyle(colorScheme.current.primaryText)

            }
            HStack {
                if !viewModel.isRunning && viewModel.seconds == 0 {
                    Button {
                        viewModel.seconds = -5
                        viewModel.startStop()
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.title)
                            .foregroundStyle(colorScheme.current.accentText)
                    }
                }
                                
                Button(viewModel.isRunning ? "Stop" : "Start") {
                    viewModel.startStop()
                }
                .tint(viewModel.isRunning ? colorScheme.current.failButton : colorScheme.current.successButton)
                .font(.largeTitle)
                .buttonStyle(.bordered)
                Button("Reset") {
                    if viewModel.isRunning {
                        viewModel.startStop()
                    }
                    viewModel.reset()
                }
                .tint(colorScheme.current.secondaryText)
                .font(.largeTitle)
                .buttonStyle(.bordered)
            }
            .padding(.top, 10)
            .preventSleep(isRunning: $viewModel.isRunning)
        }
        .padding()
        .background(colorScheme.current.cardBackground)
        .cornerRadius(15.0)
        .shadow(color: colorScheme.current.primaryText.opacity(0.5), radius: 2)
    }
}


extension String {
    func substring(index: Int) -> String {
        let arrayString = Array(self)
        return String(arrayString[index])
    }
}
