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
        
        let cornerPoints = rectangle.cornerPoints.map { $0.flipPositionY(scaleX, scaleY, originImageHeight: videoPreviewLayer.bounds.height) }
        return TrackedRectangle(cornerPoints: cornerPoints)
    }
    
    private func createShapeLayer(for rectangle: TrackedRectangle) -> CAShapeLayer {
        let strokeColor = Theme.paintColor(.secondary, alpha: 1)
        let fillColor = Theme.paintColor(.primary, alpha: 0.5)
        let layer = CAShapeLayer()
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
