import UIKit

protocol MagneticRectanglePresentationDelegate: AnyObject {
    func didHighlightAreaUpdate(_ delegate: DocumentImageView, imageInArea ciImage: CIImage)
}

final class DocumentImageView: UIImageView {
    // MARK: Namespace
    private enum Constants {
        static let defaultCornerPointViewSize: CGSize = CGSize(width: 20, height: 20)
        static let defaultMagneticAreaLineWidth: CGFloat = 4
    }
    
    // MARK: Properties
    private let cornerPointViews: [UIView] = [UIView(), UIView(), UIView(), UIView()]
    
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            setUpImage(by: ciImage)
            contentMode = .scaleAspectFit
            isUserInteractionEnabled = true
            
            if let rotatedCiImage = image?.ciImage {
                delegate?.didHighlightAreaUpdate(self, imageInArea: rotatedCiImage)
            }
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
        let uiImage = UIImage(ciImage: ciImage)
        self.image = uiImage.rotate()
    }
    
    @objc private func handlePanGesture(gesture: UIPanGestureRecognizer) {
        guard let cornerPointView = gesture.view else {
            print("UIPanGestureRecognizer에 부착된 뷰가 없습니다.")
            return
        }
        cornerPointView.center = gesture.location(in: self)
        drawHighlightLayer()
        
        if gesture.state == .ended {
            let highlightArea = calculateExtractionImageArea()
            if let cgImage = image?.cgImage?.cropping(to: highlightArea) {
                let ciImage = CIImage(cgImage: cgImage)
                delegate?.didHighlightAreaUpdate(self, imageInArea: ciImage)
            } else {
                print("non ciImage")
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
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
            cornerPointView.addGestureRecognizer(panGestureRecognizer)
            cornerPointView.backgroundColor = Theme.paintUIColor(.main, alpha: 0.5)
            cornerPointView.frame.size = Constants.defaultCornerPointViewSize
            addSubview(cornerPointView)
            cornerPointView.center = defaultCornerPointViewCenters[index]
        }
    }
    
    private func calculateExtractionImageArea() -> CGRect {
        let points = cornerPointViews.map { $0.center }
        
        let minX = points.min(by: { $0.x < $1.x })?.x ?? .zero
        let maxX = points.max(by: { $0.x < $1.x })?.x ?? .zero
        let minY = points.min(by: { $0.y < $1.y })?.y ?? .zero
        let maxY = points.max(by: { $0.y < $1.y })?.y ?? .zero
        
        let rect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        
        let imageSize = image?.size ?? CGSize(width: 1, height: 1)
        let imageScale = image?.scale ?? 1
        let scaledImageSize = CGSize(width: imageSize.width * imageScale, height: imageSize.height * imageScale)
        let scaleX = scaledImageSize.width / bounds.width
        let scaleY = scaledImageSize.height / bounds.height
        let highlightArea = CGRect(x: rect.origin.x * scaleX,
                                   y: (bounds.height - rect.maxY) * scaleY,
                                 width: rect.width * scaleX,
                                 height: rect.height * scaleY)
        return highlightArea
    }
}
