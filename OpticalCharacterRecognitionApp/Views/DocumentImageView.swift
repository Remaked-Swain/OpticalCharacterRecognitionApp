import UIKit

protocol MagneticRectanglePresentationDelegate: AnyObject {
    func didHighlightAreaUpdate(_ delegate: DocumentImageView, imageInArea ciImage: CIImage)
}

final class DocumentImageView: UIImageView {
    // MARK: Namespace
    private enum Constants {
        static let defaultCornerPointViewSize: CGSize = CGSize(width: 30, height: 30)
    }
    
    // MARK: Properties
    private let cornerPointViews: [UIView] = [UIView(), UIView(), UIView(), UIView()]
    
    private var highlightLayer: CAShapeLayer = CAShapeLayer()
    weak var delegate: MagneticRectanglePresentationDelegate?
    
    // MARK: Public
    func configure(with ciImage: CIImage) {
        setUpImage(by: ciImage)
        configureCornerPointViews()
        
        if let rotatedCiImage = image?.ciImage {
            delegate?.didHighlightAreaUpdate(self, imageInArea: rotatedCiImage)
        }
    }
    
    func updateMagneticRectangleHighlight(_ rectangle: RectangleModel) {
        let width = bounds.width
        let height = bounds.height
        let scale = CGAffineTransform.identity.scaledBy(x: width, y: height)
        
        for (index, cornerPointView) in cornerPointViews.enumerated() {
            cornerPointView.center = rectangle.cornerPoints[index].applying(scale)
        }
        
        drawHighlightLayer()
    }
}

// MARK: Private Methods
extension DocumentImageView {
    private func setUpImage(by ciImage: CIImage) {
        self.contentMode = .scaleAspectFit
        let uiImage = UIImage(ciImage: ciImage)
        self.image = uiImage.rotate()
    }
    
    @objc private func handlePanGesture(gesture: UIPanGestureRecognizer) {
        guard let cornerPointView = gesture.view else { return }
        cornerPointView.center = gesture.location(in: self)
        drawHighlightLayer()
        
        if gesture.state == .ended {
            let highlightArea = calculateExtractionImageArea()
            if let ciImage = image?.ciImage?.cropped(to: highlightArea) {
                delegate?.didHighlightAreaUpdate(self, imageInArea: ciImage)
            }
        }
    }
    
    private func drawHighlightLayer() {
        highlightLayer.path = nil
        
        let path = UIBezierPath()
        for (index, cornerPointView) in cornerPointViews.enumerated() {
            if index == 0 {
                path.move(to: cornerPointView.center)
            } else {
                path.addLine(to: cornerPointView.center)
            }
        }
        path.close()
        highlightLayer.strokeColor = Theme.paintCGColor(.sub)
        highlightLayer.path = path.cgPath
    }
}

// MARK: Configure Methods
extension DocumentImageView {
    private func configureCornerPointViews() {
        let defaultCornerPointCenters = [
            CGPoint(x: bounds.minX, y: bounds.minY),
            CGPoint(x: bounds.maxX, y: bounds.minY),
            CGPoint(x: bounds.maxX, y: bounds.maxY),
            CGPoint(x: bounds.minX, y: bounds.maxY),
        ]
        
        for (index, cornerPointView) in cornerPointViews.enumerated() {
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
            cornerPointView.addGestureRecognizer(panGestureRecognizer)
            cornerPointView.backgroundColor = Theme.paintUIColor(.main, alpha: 0.5)
            addSubview(cornerPointView)
            cornerPointView.center = defaultCornerPointCenters[index]
        }
    }
    
    private func calculateExtractionImageArea() -> CGRect {
        let points = cornerPointViews.map { $0.center }
        guard points.count == 4 else { return .zero }
        
        let minX = points.min(by: { $0.x < $1.x })?.x ?? .zero
        let maxX = points.max(by: { $0.x < $1.x })?.x ?? .zero
        let minY = points.min(by: { $0.y < $1.y })?.y ?? .zero
        let maxY = points.max(by: { $0.y < $1.y })?.y ?? .zero
        
        let rect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        
        let ciImageSize = image?.ciImage?.extent.size ?? CGSize(width: 1, height: 1)
        let scaleX = ciImageSize.width / bounds.width
        let scaleY = ciImageSize.height / bounds.height
        let highlightArea = CGRect(x: rect.origin.x * scaleX,
                                 y: (bounds.height - rect.maxY),
                                 width: rect.width * scaleX,
                                 height: rect.height * scaleY)
        return highlightArea
    }
}
