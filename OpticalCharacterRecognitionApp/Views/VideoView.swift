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
    private var currentDetectedRectangle: RectangleModel?
    
    // MARK: Public
    func updateRectangleOverlay(_ rectangle: RectangleModel, originImageRect rect: CGRect) {
        guard let currentDetectedRectangle = currentDetectedRectangle else {
            drawHighlightLayer(rectangle, originImageRect: rect)
            return
        }
        
        guard currentDetectedRectangle.isSimilar(with: rectangle) == false else {
            return
        }
        
        highlightLayer?.removeFromSuperlayer()
        drawHighlightLayer(rectangle, originImageRect: rect)
    }
    
    func removeRectangleOverlay() {
        guard highlightLayer != nil else { return }
        highlightLayer?.removeFromSuperlayer()
        highlightLayer = nil
    }
}

// MARK: Draw Methods
extension VideoView {
    private func drawHighlightLayer(_ rectangle: RectangleModel, originImageRect rect: CGRect) {
        let scaledRectangle = convertRectangleCoordinatesSpace(rectangle, originImageRect: rect)
        currentDetectedRectangle = scaledRectangle
        
        let layer = createShapeLayer(for: scaledRectangle)
        let path = createPath(for: scaledRectangle)
        layer.path = path.cgPath
        
        videoPreviewLayer.addSublayer(layer)
        highlightLayer = layer
    }
    
    private func convertRectangleCoordinatesSpace(_ rectangle: RectangleModel, originImageRect rect: CGRect) -> RectangleModel {
        let imageWidth = rect.width
        let imageHeight = rect.height
        
        let scaleX = videoPreviewLayer.bounds.width / imageWidth
        let scaleY = videoPreviewLayer.bounds.height / imageHeight
        
        let cornerPoints = rectangle.cornerPoints.map { $0.flipPositionY(scaleX, scaleY, displayTargetHeight: videoPreviewLayer.bounds.height) }
        return RectangleModel(cornerPoints: cornerPoints)
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
