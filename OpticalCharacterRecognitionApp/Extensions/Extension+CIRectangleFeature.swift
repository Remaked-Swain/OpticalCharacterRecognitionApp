import CoreImage

extension CIRectangleFeature {
    var area: CGFloat {
        let minX = min(topLeft.x, bottomLeft.x)
        let minY = min(bottomLeft.y, bottomRight.y)
        let maxX = max(bottomRight.x, topRight.x)
        let maxY = max(topLeft.y, topRight.y)
        let width = maxX - minX
        let height = maxY - minY
        return width * height
    }
}
