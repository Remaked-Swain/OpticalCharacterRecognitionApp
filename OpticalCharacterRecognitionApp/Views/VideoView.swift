import UIKit
import AVFoundation

final class VideoView: UIView {
    // MARK: Properties
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    private lazy var videoPreviewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer()
        layer.frame = self.bounds
        layer.videoGravity = .resizeAspect
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
    
    var trackedRectangle: TrackedRectangle? {
        didSet {
            Task {
                drawHighlightLayer()
            }
        }
    }
}

// MARK: Draw Methods
extension VideoView {
    private func drawHighlightLayer() {
        removeHighlightLayer()
        
        guard let trackedRectangle = trackedRectangle else { return }
        
        let convertedRect = convertRect(form: trackedRectangle.boundingBox, toViewRect: bounds)
        let newLayer = createHighlightLayer(in: convertedRect)
        highlightLayer = newLayer
        layer.addSublayer(newLayer)
    }
    
    private func createHighlightLayer(in rect: CGRect) -> CAShapeLayer {
        let path = UIBezierPath(rect: rect)
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.strokeColor = Theme.paintColor(color: .secondary, alpha: 1).cgColor
        layer.fillColor = Theme.paintColor(color: .primary, alpha: 0.5).cgColor
        layer.lineWidth = 4
        return layer
    }
    
    private func removeHighlightLayer() {
        highlightLayer?.removeFromSuperlayer()
    }
    
    private func convertRect(form rect: CGRect, toViewRect viewRect: CGRect) -> CGRect {
        let x = rect.origin.x * viewRect.width
        let y = (1 - rect.origin.y - rect.height) * viewRect.height
        let width = rect.width * viewRect.width
        let height = rect.height * viewRect.height
        return CGRect(x: x, y: y, width: width, height: height)
    }
}
