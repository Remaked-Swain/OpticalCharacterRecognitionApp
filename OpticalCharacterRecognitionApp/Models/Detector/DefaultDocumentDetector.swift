import Foundation
import CoreImage

protocol DocumentDetector: AnyObject {
    func detect(in ciImage: CIImage) throws -> RectangleModel
}

final class DefaultDocumentDetector: DocumentDetector {
    // MARK: Properties
    private let detector: CIDetector? = CIDetector(ofType: CIDetectorTypeRectangle,
                                                   context: nil)
    private let options: [String: Any] = [
        CIDetectorAccuracy: CIDetectorAccuracyHigh,
        CIDetectorAspectRatio: 1.75
    ]
    
    // MARK: Interface
    func detect(in ciImage: CIImage) throws -> RectangleModel {
        guard let rectangles = detector?.features(in: ciImage, options: options) as? [CIRectangleFeature],
              let rectangle = rectangles.first
        else {
            throw DetectError.rectangleDetectionFailed
        }
        let detectedRectangle = RectangleModel(rectangleFeature: rectangle)
        return detectedRectangle
    }
}
