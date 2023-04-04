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
            HStack(spacing: 10) {
                StopwatchUnit(timeUnit: minutes, timeUnitText: "MIN", color: .red)
                Text(":")
                    .font(.system(size: 48))
                    .offset(y: -18)
                StopwatchUnit(timeUnit: seconds, timeUnitText: "SEC", color: .blue)
            }

            HStack {
                Button(action: {
                    viewModel.startStop()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15.0)
                            .frame(width: 120, height: 50, alignment: .center)
                            .foregroundColor(viewModel.isRunning ? .pink : .green)

                        Text(viewModel.isRunning ? "Stop" : "Start")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }

                Button(action: {
                    viewModel.reset()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15.0)
                            .frame(width: 120, height: 50, alignment: .center)
                            .foregroundColor(.gray)

                        Text("Reset")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
            }
            .preventSleep(isRunning: $viewModel.isRunning)
        }
    }
}



struct StopwatchUnit: View {

    var timeUnit: Int
    var timeUnitText: String
    var color: Color

    /// Time unit expressed as String.
    /// - Includes "0" as prefix if this is less than 10.
    var timeUnitStr: String {
        let timeUnitStr = String(timeUnit)
        return timeUnit < 10 ? "0" + timeUnitStr : timeUnitStr
    }

    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 15.0)
                    .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .fill(color)
                    .frame(width: 75, height: 75, alignment: .center)

                HStack(spacing: 2) {
                    Text(timeUnitStr.substring(index: 0))
                        .font(.system(size: 48))
                        .frame(width: 28)
                    Text(timeUnitStr.substring(index: 1))
                        .font(.system(size: 48))
                        .frame(width: 28)
                }
            }

            Text(timeUnitText)
                .font(.system(size: 16))
        }
    }
}

//struct Stopwatch_Previews: PreviewProvider {
//    static var previews: some View {
//        StopwatchView()
//    }
//}

extension String {
    func substring(index: Int) -> String {
        let arrayString = Array(self)
        return String(arrayString[index])
    }
}
