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
    
    private var highlightLayer: CAShapeLayer?
    
    // MARK: Public
    func updateRectangleOverlay(_ rectangle: RectangleModel) {
        highlightLayer?.removeFromSuperlayer()
        drawHighlightLayer(rectangle)
    }
    
    func removeRectangleOverlay() {
        guard highlightLayer != nil else { return }
        highlightLayer?.removeFromSuperlayer()
        highlightLayer = nil
    }
}

// MARK: Draw Methods
extension VideoView {
    private func drawHighlightLayer(_ rectangle: RectangleModel) {
        let layer = createShapeLayer(for: rectangle)
        let path = createPath(for: rectangle)
        layer.path = path.cgPath
        
        videoPreviewLayer.addSublayer(layer)
        highlightLayer = layer
    }
    
    private func createShapeLayer(for rectangle: RectangleModel) -> CAShapeLayer {
        let strokeColor = Theme.paintCGColor(.sub, alpha: 1)
        let fillColor = Theme.paintCGColor(.main, alpha: 0.5)
        let layer = CAShapeLayer()
        layer.strokeColor = strokeColor
        layer.fillColor = fillColor
        layer.lineWidth = 4
        return layer
    }
    
    private func createPath(for rectangle: RectangleModel) -> UIBezierPath {
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
