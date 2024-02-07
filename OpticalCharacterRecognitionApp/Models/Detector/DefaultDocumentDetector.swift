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
        CIDetectorAccuracy: CIDetectorAccuracyHigh,
        CIDetectorImageOrientation: 6
    ]
    
    // MARK: Interface
    func detect(in ciImage: CIImage) -> TrackedRectangle? {
        guard let rectangles = detector?.features(in: ciImage, options: options) as? [CIRectangleFeature],
              let rectangle = rectangles.sorted(by: { $0.area > $1.area }).first
        else {
            return nil
        }
        let trackedRectangle = TrackedRectangle(rectangleFeature: rectangle)
        return trackedRectangle
    }
}
