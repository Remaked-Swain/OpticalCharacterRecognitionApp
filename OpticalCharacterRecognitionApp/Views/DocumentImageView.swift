import UIKit

final class DocumentImageView: UIImageView {
    // MARK: Namespace
    private enum Constants {
        static let defaultCornerPointViewSize: CGSize = CGSize(width: 20, height: 20)
        static let defaultMagneticAreaLineWidth: CGFloat = 4
        static let defaultMagneticAreaPadding: CGFloat = 20
    }
    
    // MARK: Properties
    private let cornerPointViews: [HighlightAreaPointView] = [
        HighlightAreaPointView(), HighlightAreaPointView(), HighlightAreaPointView(), HighlightAreaPointView()
    ]
    var highlightArea: [CGPoint] {
        cornerPointViews.map {$0.center}
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
        let padding = Constants.defaultMagneticAreaPadding
        let defaultCornerPointViewCenters = [
            CGPoint(x: bounds.minX + padding, y: bounds.minY + padding),
            CGPoint(x: bounds.maxX - padding, y: bounds.minY + padding),
            CGPoint(x: bounds.maxX - padding, y: bounds.maxY - padding),
            CGPoint(x: bounds.minX + padding, y: bounds.maxY - padding),
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
    }
}
