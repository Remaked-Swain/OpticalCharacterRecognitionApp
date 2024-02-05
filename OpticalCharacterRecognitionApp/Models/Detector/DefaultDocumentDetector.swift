import Foundation
import CoreImage

protocol DetectingProcessDelegate: AnyObject {
    func notifyDetectingResult(_ delegate: DefaultDocumentDetector, rectangle: TrackedRectangle?, error: Error?)
    func didFinishTracking(_ delegate: DefaultDocumentDetector)
}

protocol DocumentDetector: AnyObject {
    var delegate: DetectingProcessDelegate? { get set }
    func detect(on pixelBuffer: CVPixelBuffer)
}

final class DefaultDocumentDetector: DocumentDetector {
    // MARK: Properties
    private let detector: CIDetector? = CIDetector(ofType: CIDetectorTypeRectangle,
                                                   context: nil,
                                                   options: [
                                                    CIDetectorAccuracy: CIDetectorAccuracyHigh,
                                                    CIDetectorAspectRatio: NSNumber(1.75),
                                                   ])
    
    // MARK: Dependencies
    weak var delegate: DetectingProcessDelegate?
    
    // MARK: Interface
    func detect(on pixelBuffer: CVPixelBuffer) {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        guard let rectangle = detector?.features(in: ciImage).first as? CIRectangleFeature else {
            delegate?.notifyDetectingResult(self, rectangle: nil, error: DetectError.rectangleDetectionFailed)
            return
        }
        let trackedRectangle = TrackedRectangle(cgRect: rectangle.bounds)
        delegate?.notifyDetectingResult(self, rectangle: trackedRectangle, error: nil)
    }
}
