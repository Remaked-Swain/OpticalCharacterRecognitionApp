import Foundation
import CoreImage

struct Document {
    let id: UUID
    let image: CIImage
    let detectedRectangle: RectangleModel?
    
    init(id: UUID = UUID(), image: CIImage, detectedRectangle: RectangleModel? = nil) {
        self.id = id
        self.image = image
        self.detectedRectangle = detectedRectangle
    }
}
