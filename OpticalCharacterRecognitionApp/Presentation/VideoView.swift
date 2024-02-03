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
            drawHighlightLayer()
        }
    }
    
    // MARK: Public
    func removeHighlightLayer() {
        highlightLayer?.removeFromSuperlayer()
    }
}

// MARK: Draw Methods
extension VideoView {
    private func drawHighlightLayer() {
        guard let trackedRectangle = trackedRectangle else { return }
        print(trackedRectangle.boundingBox)
        var transformedRect = trackedRectangle.boundingBox
        transformedRect.origin.y = 1 - transformedRect.origin.y
        let convertedRect = videoPreviewLayer.layerRectConverted(fromMetadataOutputRect: transformedRect)
        
        removeHighlightLayer()
        
        let layer = CAShapeLayer()
        let path = UIBezierPath(rect: convertedRect)
        layer.frame = bounds
        layer.strokeColor = Theme.secondary(alpha: 1).color.cgColor
        layer.fillColor = Theme.primary(alpha: 0.5).color.cgColor
        layer.lineWidth = 4
        layer.path = path.cgPath
        
        videoPreviewLayer.addSublayer(layer)
        highlightLayer = layer
    }
}
