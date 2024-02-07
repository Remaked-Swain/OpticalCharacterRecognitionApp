import CoreImage

extension CIImage {
    func flipImageYPosition() -> CIImage {
        let transform = CGAffineTransform(scaleX: 1, y: -1)
            .translatedBy(x: 0, y: -self.extent.height)
        let transformedCIImage = self.transformed(by: transform)
        return transformedCIImage
    }
}
