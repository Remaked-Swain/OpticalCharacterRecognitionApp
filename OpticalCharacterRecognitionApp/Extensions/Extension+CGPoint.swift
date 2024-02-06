import Foundation

extension CGPoint {
    func scaled(valueX: CGFloat, valueY: CGFloat) -> CGPoint {
        return CGPoint(x: self.x * valueX, y: self.y * valueY)
    }
}
