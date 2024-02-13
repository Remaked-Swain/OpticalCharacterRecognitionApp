import UIKit
import CoreImage

protocol DocumentDetector: FilterProtocol {
    func detect(in ciImage: CIImage) throws -> RectangleModel
    func detect(in uiImage: UIImage, viewSize: CGSize) throws -> RectangleModel
}

struct DefaultDocumentDetector: DocumentDetector {
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
    
    /**
     이미지 내에 감지된 사각형 물체 좌표를 뷰 크기에 맞게 조정하여 반환합니다.
     
     만약 Core Image 좌표계를 그대로 사용하고 싶다면 다음의 메서드를 사용하세요.
     
     ```swift
     func detect(in ciImage: CIImage) throws -> RectangleModel
     ```
     */
    func detect(in uiImage: UIImage, viewSize: CGSize) throws -> RectangleModel {
        guard let ciImage = uiImage.ciImage else {
            throw DetectError.rectangleDetectionFailed
        }
        
        let rectangle = try detect(in: ciImage)
        let imageSize = uiImage.size
        let scaleX = imageSize.width / viewSize.width
        let scaleY = imageSize.height / viewSize.height
        let newCornerPoints = rectangle.cornerPoints.map({ $0.flipPositionY(scaleX, scaleY, displayTargetHeight: viewSize.height) })
        return RectangleModel(cornerPoints: newCornerPoints)
    }
}
