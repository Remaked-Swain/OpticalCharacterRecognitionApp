import UIKit

protocol MagneticRectanglePresentationDelegate: AnyObject {
    func didImageUpdate(_ delegate: DocumentImageView, image: UIImage)
}

final class DocumentImageView: UIImageView {
    // MARK: Namespace
    private enum Constants {
        static let defaultCornerPointViewSize: CGSize = CGSize(width: 20, height: 20)
        static let defaultMagneticAreaLineWidth: CGFloat = 4
    }
    
    // MARK: Properties
    private let cornerPointViews: [HighlightAreaPointView] = [
        HighlightAreaPointView(), HighlightAreaPointView(), HighlightAreaPointView(), HighlightAreaPointView()
    ]
    private var highlightArea: CGRect {
        let points = cornerPointViews.map { $0.center }
        let minX = points.min(by: { $0.x < $1.x })?.x ?? .zero
        let maxX = points.max(by: { $0.x < $1.x })?.x ?? .zero
        let minY = points.min(by: { $0.y < $1.y })?.y ?? .zero
        let maxY = points.max(by: { $0.y < $1.y })?.y ?? .zero
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    private lazy var highlightLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = Theme.paintCGColor(.sub)
        layer.fillColor = nil
        layer.lineWidth = Constants.defaultMagneticAreaLineWidth
        layer.lineCap = .round
        layer.lineJoin = .round
        self.layer.addSublayer(layer)
        return layer
    }()
    
    weak var delegate: MagneticRectanglePresentationDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureCornerPointViews()
    }
    
    // MARK: Public
    func configure(with ciImage: CIImage) {
        setUpImage(by: ciImage)
        contentMode = .scaleAspectFit
        isUserInteractionEnabled = true
        drawHighlightLayer()
    }
    
    func updateMagneticRectangleHighlight(_ rectangle: RectangleModel) {
        for (index, cornerPointView) in cornerPointViews.enumerated() {
            cornerPointView.moveLocation(rectangle.cornerPoints[index])
        }
        drawHighlightLayer()
    }
}

// MARK: Private Methods
extension DocumentImageView {
    private func setUpImage(by ciImage: CIImage) {
        let uiImage = UIImage(ciImage: ciImage)
        self.image = uiImage.rotate()
        
        if let image = self.image {
            delegate?.didImageUpdate(self, image: image)
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
        highlightLayer.path = path.cgPath
    }
}

// MARK: Configure Methods
extension DocumentImageView {
    private func configureCornerPointViews() {
        let defaultCornerPointViewCenters = [
            CGPoint(x: bounds.minX, y: bounds.minY),
            CGPoint(x: bounds.maxX, y: bounds.minY),
            CGPoint(x: bounds.maxX, y: bounds.maxY),
            CGPoint(x: bounds.minX, y: bounds.maxY),
        ]
        
        for (index, cornerPointView) in cornerPointViews.enumerated() {
            cornerPointView.delegate = self
            cornerPointView.configurePointView(from: self, center: defaultCornerPointViewCenters[index])
        }
    }
}

// MARK: HighlightAreaDrawingDelegate
extension DocumentImageView: HighlightAreaDrawingDelegate {
    func drawHighlightArea(_ delegate: HighlightAreaPointView) {
        drawHighlightLayer()
        guard let cgImage = self.image?.cgImage?.cropping(to: highlightArea) else { return }
        let croppedImage = UIImage(cgImage: cgImage)
        self.delegate?.didImageUpdate(self, image: croppedImage)
    }
}
