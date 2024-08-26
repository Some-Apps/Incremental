import Foundation
import SwiftUI
import SwiftData

@Model class PhotoProgression: Identifiable {
    var id: UUID?
    var name: String?
    private var photoData: [Data]?

    init(id: UUID? = nil, name: String? = nil, photos: [UIImage]? = nil) {
        self.id = id
        self.name = name
        self.photoData = photos?.compactMap { $0.pngData() }
    }
    
    // Computed property to get UIImage array from Data array
    var photos: [UIImage]? {
        get {
            return photoData?.compactMap { UIImage(data: $0) }
        }
        set {
            photoData = newValue?.compactMap { $0.pngData() }
        }
    }
}
