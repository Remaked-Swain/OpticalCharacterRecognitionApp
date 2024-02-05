import CoreImage

enum FilterType {
    case perspectiveCorrection
    
    var name: String {
        switch self {
        case .perspectiveCorrection:
            "CIPerspectiveCorrection"
        }
    }
}

//var ciImage = CIImage(cvPixelBuffer: pixelBuffer)
//let topLeft = rectangle.topLeft.scaled(to: ciImage.extent.size)
//let topRight = rectangle.topRight.scaled(to: ciImage.extent.size)
//let bottomLeft = rectangle.bottomLeft.scaled(to: ciImage.extent.size)
//let bottomRight = rectangle.bottomRight.scaled(to: ciImage.extent.size)
//ciImage = ciImage.applyingFilter(FilterType.perspectiveCorrection.name,
//                                 parameters: [
//                                    "inputTopLeft": CIVector(cgPoint: topLeft),
//                                    "inputTopRight": CIVector(cgPoint: topRight),
//                                    "inputBottomLeft": CIVector(cgPoint: bottomLeft),
//                                    "inputBottomRight": CIVector(cgPoint: bottomRight),
//                                 ])
