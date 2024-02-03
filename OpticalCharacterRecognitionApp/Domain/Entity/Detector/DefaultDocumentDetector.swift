import Foundation
import CoreImage

protocol DocumentDetector {
    func detect(in ciImage: CIImage) throws -> CIRectangleFeature
}

final class DefaultDocumentDetector: DocumentDetector {
    
    // MARK: Properties
    private let detector: CIDetector? = CIDetector(ofType: CIDetectorTypeRectangle,
                                                  context: nil,
                                                  options: [
                                                    CIDetectorAccuracy: CIDetectorAccuracyHigh,
                                                    CIDetectorMinFeatureSize: NSNumber(0.3)
                                                  ])
    private let options: [String: Any]? = [CIDetectorAspectRatio: NSNumber(1.414)]
    
    // MARK: Interface
    func detect(in ciImage: CIImage) throws -> CIRectangleFeature {
        let rectangles = try extractFeature(in: ciImage, options: options)
        guard let biggestRectangle = findBiggestRectangleFeature(with: rectangles) else {
            throw DetectError.detectFailed
        }
        return biggestRectangle
    }
}

// MARK: Private Methods
extension DefaultDocumentDetector {
    private func extractFeature(in ciImage: CIImage, options: [String: Any]?) throws -> [CIRectangleFeature] {
        guard let rectangles = detector?.features(in: ciImage, options: options) as? [CIRectangleFeature] else {
            throw DetectError.imageNotFound
        }
        return rectangles
    }
    
    private func findBiggestRectangleFeature(with rectangles: [CIRectangleFeature]) -> CIRectangleFeature? {
        return rectangles.sorted {
            $0.area > $1.area
        }.first
    }
}
