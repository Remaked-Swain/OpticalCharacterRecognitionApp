import CoreImage
import Foundation

protocol FilterProtocol {
    func filter(filterType type: FilterType, image: CIImage, rectangle: RectangleModel) -> CIImage
}

struct Filter: FilterProtocol {
    func filter(filterType type: FilterType, image: CIImage, rectangle: RectangleModel) -> CIImage {
        let filteredImage = image.applyingFilter(type.name,
                                                 parameters: [
                                                    "inputTopLeft": CIVector(cgPoint: rectangle.topLeft),
                                                    "inputTopRight": CIVector(cgPoint: rectangle.topRight),
                                                    "inputBottomLeft": CIVector(cgPoint: rectangle.bottomLeft),
                                                    "inputBottomRight": CIVector(cgPoint: rectangle.bottomRight),
                                                 ])
        
        return filteredImage
    }
}
