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
