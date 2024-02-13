import UIKit
import CoreImage

protocol DocumentDetector: FilterProtocol {
    func detect(in ciImage: CIImage, forType detectionType: DetectorType) throws -> RectangleModel
}

struct DefaultDocumentDetector: DocumentDetector {
    // MARK: Properties
    private let detector: CIDetector? = CIDetector(ofType: CIDetectorTypeRectangle,
                                                   context: nil)
    
    // MARK: Interface
    func detect(in ciImage: CIImage, forType detectionType: DetectorType) throws -> RectangleModel {
        guard let rectangles = detector?.features(in: ciImage, options: detectionType.options) as? [CIRectangleFeature],
              let rectangle = rectangles.first
        else {
            throw DetectError.rectangleDetectionFailed
        }
        let detectedRectangle = RectangleModel(rectangleFeature: rectangle)
        return detectedRectangle
    }
}
