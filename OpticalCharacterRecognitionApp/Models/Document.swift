import Foundation
import CoreImage

struct Document {
    let id: UUID
    let image: CIImage
    let detectedRectangle: TrackedRectangle
    
    init(id: UUID = UUID(), image: CIImage, detectedRectangle: TrackedRectangle) {
        self.id = id
        self.image = image
        self.detectedRectangle = detectedRectangle
    }
}
