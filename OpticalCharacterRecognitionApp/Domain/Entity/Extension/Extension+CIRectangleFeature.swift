import CoreImage

extension CIRectangleFeature {
    var area: CGFloat {
        let minX = min(self.topLeft.x, self.bottomLeft.x)
        let minY = min(self.bottomLeft.y, self.bottomRight.y)
        let maxX = max(self.bottomRight.x, self.topRight.x)
        let maxY = max(self.topLeft.y, self.topRight.y)
        let width = maxX - minX
        let height = maxY - minY
        return width * height
    }
}
