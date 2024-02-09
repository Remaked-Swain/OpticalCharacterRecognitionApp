import Foundation

extension CGPoint {
    func flipPositionY(_ scaleX: Double, _ scaleY: Double, displayTargetHeight height: CGFloat) -> Self {
        return Self(x: self.x * scaleX, y: height - (self.y * scaleY))
    }
    
    /**
     두 점의 좌표 차이를 구합니다.
     */
    func distance(to point: Self) -> CGFloat {
        let dx = self.x - point.x
        let dy = self.y - point.y
        return sqrt(dx * dx + dy * dy)
    }
}
