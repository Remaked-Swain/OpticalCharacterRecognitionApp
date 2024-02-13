import Foundation

extension CGPoint {
    /**
     목표한 높이만큼의 규모 내에서 Y축을 반전시킵니다.
     
     목표한 높이만큼의 스케일링 후 X좌표와 Y좌표가 서로 바뀝니다.
     */
    func flipPositionY(_ scaleX: Double, _ scaleY: Double, displayTargetHeight height: CGFloat) -> Self {
        return Self(x: self.x * scaleX, y: height - (self.y * scaleY))
    }
    
    /**
     두 점의 좌표 차이를 구합니다.
     */
    func distance(to point: Self) -> CGFloat {
        let dx = self.x - point.x
        let dy = self.y - point.y
        let distance = sqrt(dx * dx + dy * dy)
        return distance
    }
}
