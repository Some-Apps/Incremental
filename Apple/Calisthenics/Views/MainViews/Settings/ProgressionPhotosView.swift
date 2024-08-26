import SwiftUI
import SwiftData
import AlertToast
import AVFoundation
import UIKit

struct ProgressionPhotosView: View {
    @Environment(\.modelContext) var modelContext

    @State private var isAddingNewProgression = false
    @State private var confirmDelete = false
    @State private var indexSetToDelete: IndexSet?
    @Query(filter: #Predicate<PhotoProgression> {item in
        true
    }, sort: \.name) var progressions: [PhotoProgression]

    var body: some View {
            List {
                ForEach(progressions) { progression in
                    NavigationLink(destination: ProgressionDetailView(progression: progression)) {
                        Text(progression.name ?? "")
                    }
                }
                .onDelete(perform: { indexSet in
                    indexSetToDelete = indexSet
                    confirmDelete = true
                })
                
            }
            .confirmationDialog("Are you sure you want to delete this progression?", isPresented: $confirmDelete, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    if let indexSet = indexSetToDelete {
                        deleteProgression(at: indexSet)
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
            .navigationTitle("Progressions")
            .toolbar {
                Button(action: { isAddingNewProgression = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $isAddingNewProgression) {
                AddProgressionView()
            }
    }
    
    private func deleteProgression(at offsets: IndexSet) {
        for index in offsets {
            let progression = progressions[index]
            modelContext.delete(progression)
        }
        
        do {
            try modelContext.save()
            indexSetToDelete = nil
        } catch {
            print("Failed to save context after deleting progression: \(error)")
        }
    }
}


struct AddProgressionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @State private var progressionName = ""
    @State private var selectedImage: UIImage?
    @State private var isTakingPhoto = false
    @State private var showCamera = false
    @State private var isSaving = false
    @State private var showToast = false

    var body: some View {
        Form {
            Section(header: Text("Progression Name")) {
                TextField("Enter progression name", text: $progressionName)
            }

            Section {
                // Take photo
                Button("Open Camera") {
                    self.showCamera.toggle()
                }
                .fullScreenCover(isPresented: self.$showCamera) {
                    CustomCameraView(selectedImage: $selectedImage, overlay: nil)
                        .ignoresSafeArea(.all)
                }
                if let chosenImage = selectedImage {
                    Image(uiImage: chosenImage)
                        .resizable()
                        .scaledToFit()
                }
            }

            Section {
                Button("Save") {
                    if !progressionName.isEmpty, let firstPhoto = selectedImage {
                        isSaving = true
                        showToast = true
                        addProgression(firstPhoto: firstPhoto)
                    }
                }
                .disabled(progressionName.isEmpty || selectedImage == nil)
            }
        }
        .navigationTitle("New Progression")
        .toast(isPresenting: $showToast) {
            AlertToast(type: .loading, title: "Saving...")
        }
    }
    
    func addProgression(firstPhoto: UIImage) {
        DispatchQueue.global(qos: .userInitiated).async {
            let newProgression = PhotoProgression(name: progressionName, photos: [firstPhoto])
            modelContext.insert(newProgression)
            do {
                try modelContext.save()
                DispatchQueue.main.async {
                    isSaving = false
                    dismiss()
                }
            } catch {
                DispatchQueue.main.async {
                    isSaving = false
                    showToast = false
                    print("Failed to save context after adding progression: \(error)")
                }
            }
        }
    }
}




struct ProgressionDetailView: View {
    @Environment(\.modelContext) private var modelContext

    @State var progression: PhotoProgression
    @Query(filter: #Predicate<PhotoProgression> {item in
        true
    }, sort: \.name) var progressions: [PhotoProgression]
    @State private var isAddingNewPhoto = false
    
    @State private var newPhoto: UIImage?
    
    var thisProgression: PhotoProgression? {
        return progressions.first(where: { $0.id == progression.id }) ?? nil
    }
    
    var body: some View {
        VStack {
            List {
                if let thisProgression = thisProgression {
                    if let photos = thisProgression.photos {
                        ForEach(photos, id: \.self) { photo in
                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }
                
                
            }
            .navigationTitle(thisProgression?.name ?? "")
            .toolbar {
                Button(action: { isAddingNewPhoto = true }) {
                    Image(systemName: "camera")
                }
                .fullScreenCover(isPresented: self.$isAddingNewPhoto) {
                    if let thisProgression = thisProgression {
                        if let firstPhoto = thisProgression.photos?.first {
                            CustomCameraView(selectedImage: $newPhoto, overlay: firstPhoto)
                        }
                    }
                    
                }
            }
        }
        .onChange(of: newPhoto) {
            if let newPhoto = newPhoto {
                progression.photos?.append(newPhoto)
                try? modelContext.save()
            }
        }
    }
}




struct CustomCameraView: View {
    @StateObject private var camera = CameraViewModel()
    @Binding var selectedImage: UIImage?
    let overlay: UIImage?
    @Environment(\.presentationMode) var isPresented

    var body: some View {
        ZStack {
            CameraPreview(session: camera.session)
                .ignoresSafeArea(.all)
                .scaledToFit()
            if let overlay = overlay {
                Image(uiImage: overlay)
                    .resizable()
                    .scaledToFit()
                    .opacity(0.5)
                    .ignoresSafeArea(.all)
            }
            
            VStack {
                Spacer()
                
                Button(action: {
                    camera.takePhoto()
                }) {
                    Image(systemName: "camera.circle")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            camera.configure()
        }
        .onDisappear {
            camera.stopSession()
        }
        .onChange(of: camera.capturedImage) {
            if let image = camera.capturedImage {
                selectedImage = image
                isPresented.wrappedValue.dismiss()
            }
        }
    }
}

class CameraViewModel: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var capturedImage: UIImage?
    private var output = AVCapturePhotoOutput()
    
    func configure() {
        session.beginConfiguration()
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        session.commitConfiguration()
        
        startSession()
    }
    
    func startSession() {
        session.startRunning()
    }
    
    func stopSession() {
        session.stopRunning()
    }
    
    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            return
        }
        
        DispatchQueue.main.async {
            self.capturedImage = image
        }
    }
}


struct CameraPreview: UIViewRepresentable {
    var session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update if necessary
    }
}
