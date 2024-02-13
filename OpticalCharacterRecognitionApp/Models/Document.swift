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

// MARK: Hashable Confirmation
extension Document: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Document, rhs: Document) -> Bool {
        return lhs.id == rhs.id
    }
}
