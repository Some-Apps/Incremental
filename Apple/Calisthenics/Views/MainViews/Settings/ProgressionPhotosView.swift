import SwiftUI
import Combine
import UIKit

struct ProgressionPhotosView: View {
    @StateObject private var viewModel = ProgressionPhotosViewModel()
    @State private var isPresentingPhotoPicker = false
    @State private var selectedProgression: Progression?
    @State private var progressionName: String = ""
    
    var body: some View {
            List {
                ForEach(viewModel.progressions) { progression in
                    NavigationLink(destination: ProgressionDetailView(progression: progression, viewModel: viewModel)) {
                        Text(progression.name)
                    }
                }
            }
            .navigationBarTitle("Progressions")
            .navigationBarItems(trailing: Button(action: {
                isPresentingPhotoPicker = true
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $isPresentingPhotoPicker) {
                ProgressionCreationView(viewModel: viewModel, isPresented: $isPresentingPhotoPicker)
            }
    }
}


struct Progression: Identifiable {
    let id = UUID()
    var name: String
    var photos: [UIImage] = []
}

class ProgressionPhotosViewModel: ObservableObject {
    @Published var progressions: [Progression] = []
    
    func addProgression(name: String) {
        let newProgression = Progression(name: name)
        progressions.append(newProgression)
    }
    
    func addPhoto(to progression: Progression, photo: UIImage) {
        if let index = progressions.firstIndex(where: { $0.id == progression.id }) {
            progressions[index].photos.append(photo)
        }
    }
}

struct ProgressionDetailView: View {
    var progression: Progression
    @ObservedObject var viewModel: ProgressionPhotosViewModel
    @State private var isShowingCamera = false

    var body: some View {
        VStack {
            ScrollView {
                ForEach(progression.photos, id: \.self) { photo in
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .padding()
                }
            }

            Button(action: {
                isShowingCamera = true
            }) {
                Text("Add Photo")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding()
        }
        .navigationTitle(progression.name)
        .sheet(isPresented: $isShowingCamera) {
            CameraView(overlayImage: progression.photos.first, onPhotoCaptured: { image in
                viewModel.addPhoto(to: progression, photo: image)
            })
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    var overlayImage: UIImage?
    var onPhotoCaptured: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        
        DispatchQueue.main.async {
            let screenSize = UIScreen.main.bounds.size
            let cameraAspectRatio: CGFloat = 4.0 / 3.0
            let cameraHeight = screenSize.width * cameraAspectRatio
            let cameraFrame = CGRect(x: 0, y: (screenSize.height - cameraHeight) / 2, width: screenSize.width, height: cameraHeight)
            
            print("Screen size: \(screenSize)")
            print("Camera frame: \(cameraFrame)")
            
            if let overlayImage = overlayImage?.withAlpha(0.5) {
                let overlayImageView = UIImageView(image: overlayImage)
                overlayImageView.contentMode = .scaleAspectFit
                overlayImageView.frame = cameraFrame
                picker.cameraOverlayView = overlayImageView
            }
        }

        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                let correctedImage = image.correctedOrientation(img: image)
                parent.onPhotoCaptured(correctedImage)
            }
            picker.dismiss(animated: true)
        }
    }
}



struct ProgressionCreationView: View {
    @ObservedObject var viewModel: ProgressionPhotosViewModel
    @Binding var isPresented: Bool
    @State private var name: String = ""
    @State private var isShowingCamera = false
    @State private var firstPhoto: UIImage?

    var body: some View {
        VStack {
            TextField("Progression Name", text: $name)
                .padding()

            Button("Take First Photo") {
                isShowingCamera = true
            }
            .padding()

            Spacer()

            Button("Create Progression") {
                if let firstPhoto = firstPhoto, !name.isEmpty {
                    var progression = Progression(name: name)
                    progression.photos.append(firstPhoto)
                    viewModel.progressions.append(progression)
                    isPresented = false
                }
            }
            .disabled(firstPhoto == nil || name.isEmpty)
            .padding()
        }
        .sheet(isPresented: $isShowingCamera) {
            CameraView(overlayImage: nil, onPhotoCaptured: { image in
                firstPhoto = image
            })
        }
    }
}

extension UIImage {
    func withAlpha(_ alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context = UIGraphicsGetCurrentContext()!
        let rect = CGRect(origin: .zero, size: size)
        
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(.normal)
        context.setAlpha(alpha)
        context.draw(cgImage!, in: rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage?.correctedOrientation(img: newImage!)
    }
}


extension UIImage {

    func correctedOrientation(img:UIImage) -> UIImage {

        if (img.imageOrientation == UIImage.Orientation.up) {
          return img;
      }

      UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale);
      let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)

let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
      UIGraphicsEndImageContext();
      return normalizedImage;

    }

}

