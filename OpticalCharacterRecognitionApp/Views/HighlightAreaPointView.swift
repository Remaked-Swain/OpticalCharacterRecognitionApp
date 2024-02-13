import UIKit

protocol HighlightAreaDrawingDelegate: AnyObject {
    func drawHighlightArea(_ delegate: HighlightAreaPointView)
}

final class HighlightAreaPointView: UIView {
    // MARK: Namespace
    private enum Constants {
        static let defaultSizeRatio: CGFloat = 0.1
    }
    
    // MARK: Properties
    weak var delegate: HighlightAreaDrawingDelegate?
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let touch = touches.first else { return }
        let point = touch.location(in: self.superview)
        self.center = point
        delegate?.drawHighlightArea(self)
    }
    
    // MARK: Public
    func configurePointView(from superView: UIView, center: CGPoint) {
        superView.addSubview(self)
        backgroundColor = Theme.paintUIColor(.main, alpha: 0.5)
        let width = superView.bounds.width * Constants.defaultSizeRatio
        
        self.bounds = CGRect(x: .zero, y: .zero, width: width, height: width)
        self.layer.cornerRadius = frame.width / 2
        self.center = center
        delegate?.drawHighlightArea(self)
    }
    
    func moveLocation(_ center: CGPoint) {
        self.center = center
        delegate?.drawHighlightArea(self)
    }
}
