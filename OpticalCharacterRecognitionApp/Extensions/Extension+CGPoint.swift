import Foundation

extension CGPoint {
    func flipPositionY(_ scaleX: Double, _ scaleY: Double, originImageHeight height: CGFloat) -> Self {
        return Self(x: self.x * scaleX, y: height - (self.y * scaleY))
    }
}
