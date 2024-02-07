import UIKit
import AVFoundation

final class VideoView: UIView {
    // MARK: Properties
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    lazy var videoPreviewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer()
        layer.videoGravity = .resize
        self.layer.addSublayer(layer)
        return layer
    }()
    
    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }
    
    private var highlightLayer: CAShapeLayer?
    
    // MARK: Public
    func updateRectangleOverlay(_ rectangle: TrackedRectangle, originImageRect rect: CGRect) {
        highlightLayer?.removeFromSuperlayer()
        
        let scaledRectangle = convertRectangleCoordinatesSpace(rectangle, originImageRect: rect)
        
        let layer = createShapeLayer(for: scaledRectangle)
        let path = createPath(for: scaledRectangle)
        layer.path = path.cgPath
        
        videoPreviewLayer.addSublayer(layer)
        highlightLayer = layer
    }
}

// MARK: Draw Methods
extension VideoView {
    private func convertRectangleCoordinatesSpace(_ rectangle: TrackedRectangle, originImageRect rect: CGRect) -> TrackedRectangle {
        let imageWidth = rect.width
        let imageHeight = rect.height
        
        let scaleX = videoPreviewLayer.bounds.width / imageWidth
        let scaleY = videoPreviewLayer.bounds.height / imageHeight
        
        // 사각형을 90도 회전하기 위한 회전 변환 행렬을 생성합니다.
//        let rotationTransform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2.0)
        
        // 변환된 좌표를 계산합니다. 회전 변환 후 좌표를 정확히 계산하기 위해 회전 변환 행렬을 먼저 적용합니다.
//        let scaledTopLeft = rectangle.topLeft.applying(rotationTransform)
//        let scaledTopRight = rectangle.topRight.applying(rotationTransform)
//        let scaledBottomLeft = rectangle.bottomLeft.applying(rotationTransform)
//        let scaledBottomRight = rectangle.bottomRight.applying(rotationTransform)
        
        let scaledTopLeft = rectangle.topLeft
        let scaledTopRight = rectangle.topRight
        let scaledBottomLeft = rectangle.bottomLeft
        let scaledBottomRight = rectangle.bottomRight
        
        // 이후에 스케일 변환을 적용합니다.
        let rotatedScaledTopLeft = CGPoint(x: scaledTopLeft.y * scaleX, y: (imageWidth - scaledTopLeft.x) * scaleY)
        let rotatedScaledTopRight = CGPoint(x: scaledTopRight.y * scaleX, y: (imageWidth - scaledTopRight.x) * scaleY)
        let rotatedScaledBottomLeft = CGPoint(x: scaledBottomLeft.y * scaleX, y: (imageWidth - scaledBottomLeft.x) * scaleY)
        let rotatedScaledBottomRight = CGPoint(x: scaledBottomRight.y * scaleX, y: (imageWidth - scaledBottomRight.x) * scaleY)
        
        // 변환된 좌표로 새로운 TrackedRectangle을 생성하여 반환합니다.
        return TrackedRectangle(topLeft: rotatedScaledTopLeft, topRight: rotatedScaledTopRight, bottomLeft: rotatedScaledBottomLeft, bottomRight: rotatedScaledBottomRight)
    }
    
    private func createShapeLayer(for rectangle: TrackedRectangle) -> CAShapeLayer {
        let strokeColor = Theme.paintColor(color: .secondary, alpha: 1).cgColor
        let fillColor = Theme.paintColor(color: .primary, alpha: 0.5).cgColor
        let layer = CAShapeLayer()
        layer.frame = rectangle.boundingBox
        layer.strokeColor = strokeColor
        layer.fillColor = fillColor
        layer.lineWidth = 4
        return layer
    }
    
    private func createPath(for rectangle: TrackedRectangle) -> UIBezierPath {
        let path = UIBezierPath()
        for (index, point) in rectangle.cornerPoints.enumerated() {
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.close()
        return path
    }
}
