import SwiftUI
import SwiftData
import UIKit

struct ExerciseProportionsView: View {
    var exercises: [Exercise]

    var body: some View {
        VStack(spacing: 5) {
            Text("Exercise Proportions")
                .font(.largeTitle)
                .bold()
            
            ForEach(exercises, id: \.self) { exercise in
                HStack {
                    Text(exercise.title ?? "Unknown")
                        .font(.headline)
                    Spacer()
                    // Convert reps to an Int so there’s no decimal
                    Text("\(Int(exercise.logs?.last?.reps ?? 0)) reps")
                        .font(.subheadline)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.accentColor.opacity(0.1))
                )
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
    }
}

extension View {
    func asImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
