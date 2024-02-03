import Foundation
import Vision

struct TrackedRectangle {
    let topLeft: CGPoint
    let topRight: CGPoint
    let bottomLeft: CGPoint
    let bottomRight: CGPoint
    
    var cornerPoints: [CGPoint] {
        return [topLeft, topRight, bottomRight, bottomLeft]
    }
    
    var boundingBox: CGRect {
        let topLeftRect = CGRect(origin: topLeft, size: .zero)
        let topRightRect = CGRect(origin: topRight, size: .zero)
        let bottomLeftRect = CGRect(origin: bottomLeft, size: .zero)
        let bottomRightRect = CGRect(origin: bottomRight, size: .zero)
        
        return topLeftRect.union(topRightRect).union(bottomLeftRect).union(bottomRightRect)
    }
    
    var area: CGFloat {
        let minX = min(topLeft.x, bottomLeft.x)
        let minY = min(bottomLeft.y, bottomRight.y)
        let maxX = max(bottomRight.x, topRight.x)
        let maxY = max(topLeft.y, topRight.y)
        let width = maxX - minX
        let height = maxY - minY
        return width * height
    }
    
    init(observation: VNRectangleObservation) {
        self.topLeft = observation.topLeft
        self.topRight = observation.topRight
        self.bottomLeft = observation.bottomLeft
        self.bottomRight = observation.bottomRight
    }
    
    init(cgRect: CGRect) {
        self.topLeft = CGPoint(x: cgRect.minX, y: cgRect.maxY)
        self.topRight = CGPoint(x: cgRect.maxX, y: cgRect.maxY)
        self.bottomLeft = CGPoint(x: cgRect.minX, y: cgRect.minY)
        self.bottomRight = CGPoint(x: cgRect.maxX, y: cgRect.minY)
    }
}
