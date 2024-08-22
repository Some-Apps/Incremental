import SwiftUI
import AVFoundation
import MijickCameraView

struct Progression: Identifiable {
    var id = UUID()
    var name: String
    var photos: [UIImage] = []
}

struct ProgressionPhotosView: View {
    @State private var progressions: [Progression] = []
    @State private var isAddingNewProgression = false

    var body: some View {
            List {
                ForEach(progressions) { progression in
                    NavigationLink(destination: ProgressionDetailView(progression: progression)) {
                        Text(progression.name)
                    }
                }
            }
            .navigationTitle("Progressions")
            .toolbar {
                Button(action: { isAddingNewProgression = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $isAddingNewProgression) {
                AddProgressionView(progressions: $progressions)
            }
        
    }
}

struct AddProgressionView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var progressions: [Progression]
    @State private var progressionName = ""
    @State private var selectedImage: UIImage?
    @State private var isTakingPhoto = false

    var body: some View {
        Form {
            Section(header: Text("Progression Name")) {
                TextField("Enter progression name", text: $progressionName)
            }

            Section(header: Text("Take First Photo")) {
                Button("Capture Photo") {
                    isTakingPhoto = true
                }
                .sheet(isPresented: $isTakingPhoto) {
                    CameraView()
                }

                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .clipped()
                }
            }

            Section {
                Button("Save") {
                    if !progressionName.isEmpty, let firstPhoto = selectedImage {
                        let newProgression = Progression(name: progressionName, photos: [firstPhoto])
                        progressions.append(newProgression)
                        dismiss()
                    }
                }
                .disabled(progressionName.isEmpty || selectedImage == nil)
            }
        }
        .navigationTitle("New Progression")
    }
}

struct ProgressionDetailView: View {
    @State var progression: Progression
    @State private var isAddingNewPhoto = false

    var body: some View {
        VStack {
            List {
                ForEach(progression.photos, id: \.self) { photo in
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFit()
                }
            }
            .navigationTitle(progression.name)
            .toolbar {
                Button(action: { isAddingNewPhoto = true }) {
                    Image(systemName: "camera")
                }
            }
            .sheet(isPresented: $isAddingNewPhoto) {
                AddPhotoView(progression: $progression)
            }
        }
    }
}

struct AddPhotoView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var progression: Progression
    @State private var capturedImage: UIImage?

    var body: some View {
        VStack {
            if let firstPhoto = progression.photos.first {
                ZStack {
                    CameraView()
                    Image(uiImage: firstPhoto)
                        .resizable()
                        .scaledToFit()
                        .opacity(0.5)
                        .frame(height: 300)
                }
            } else {
                CameraView()
            }

            Button("Capture Photo") {
                if let newPhoto = capturedImage {
                    progression.photos.append(newPhoto)
                    dismiss()
                }
            }
            .padding()
        }
        .navigationTitle("Capture Photo")
    }
}


struct CameraView: View {
    @ObservedObject private var manager: CameraManager = .init(
        outputType: .photo,
        cameraPosition: .back,
//        cameraFilters: [.init(name: "CISepiaTone")!],
        resolution: .hd4K3840x2160,
        frameRate: 25,
        flashMode: .off,
        isGridVisible: false,
        focusImageColor: .yellow,
        focusImageSize: 92
    )


   
    var body: some View {
        MCameraController(manager: manager)
            .onImageCaptured { data in
                            print("IMAGE CAPTURED")
                        }
                        .onVideoCaptured { url in
                            print("VIDEO CAPTURED")
                        }
                        .afterMediaCaptured { $0
                            .closeCameraController(true)
                            .custom { print("Media object has been successfully captured") }
                        }
                        .onCloseController {
                            print("CLOSE THE CONTROLLER")
                        }
    }
}
