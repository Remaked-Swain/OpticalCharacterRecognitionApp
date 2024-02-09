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
    
    func changeDocument(newImage: CIImage? = nil, newDetectedRectangle: RectangleModel? = nil) -> Self {
        let newDocument = Document(id: self.id,
                                   image: newImage ?? self.image,
                                   detectedRectangle: newDetectedRectangle ?? self.detectedRectangle)
        return newDocument
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
