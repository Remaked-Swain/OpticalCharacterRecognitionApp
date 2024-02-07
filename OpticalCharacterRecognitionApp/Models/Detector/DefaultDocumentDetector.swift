import Foundation
import CoreImage

protocol DocumentDetector: AnyObject {
    func detect(in ciImage: CIImage) -> TrackedRectangle?
}

final class DefaultDocumentDetector: DocumentDetector {
    // MARK: Properties
    private let detector: CIDetector? = CIDetector(ofType: CIDetectorTypeRectangle,
                                                   context: nil)
    private let options: [String: Any] = [
        CIDetectorAccuracy: CIDetectorAccuracyHigh
    ]
    
    // MARK: Interface
    func detect(in ciImage: CIImage) -> TrackedRectangle? {
        guard let rectangles = detector?.features(in: ciImage, options: options) as? [CIRectangleFeature],
              let rectangle = rectangles.first
        else {
            return nil
        }
        let trackedRectangle = TrackedRectangle(rectangleFeature: rectangle)
        return trackedRectangle
    }
}
