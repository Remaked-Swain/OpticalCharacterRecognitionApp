import Foundation
import CoreImage

protocol DocumentDetector: AnyObject {
    func detect(in ciImage: CIImage) -> TrackedRectangle?
}

final class DefaultDocumentDetector: DocumentDetector {
    // MARK: Properties
    private let detector: CIDetector? = CIDetector(ofType: CIDetectorTypeRectangle,
                                                   context: nil,
                                                   options: [
                                                    CIDetectorAccuracy: CIDetectorAccuracyHigh,
                                                    CIDetectorAspectRatio: NSNumber(1.75),
                                                   ])
    
    // MARK: Interface
    func detect(in ciImage: CIImage) -> TrackedRectangle? {
        guard let rectangle = detector?.features(in: ciImage).first as? CIRectangleFeature else {
            return nil
        }
        let trackedRectangle = TrackedRectangle(rectangleFeature: rectangle)
        return trackedRectangle
    }
}
