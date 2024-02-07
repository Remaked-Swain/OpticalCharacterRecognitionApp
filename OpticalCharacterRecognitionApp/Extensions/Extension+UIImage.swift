import UIKit

extension UIImage {
    func rotate(by degrees: CGFloat) -> UIImage {
        let radians = degrees * .pi / 180
        let newRect = CGRect(origin: .zero, size: self.size)
            .applying(CGAffineTransform(rotationAngle: radians))
        let renderer = UIGraphicsImageRenderer(size: newRect.size)
        
        let image = renderer.image { context in
            context.cgContext.translateBy(x: newRect.width / 2, y: newRect.height / 2)
            context.cgContext.rotate(by: radians)
            draw(in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
        }
        
        return image
    }
}
