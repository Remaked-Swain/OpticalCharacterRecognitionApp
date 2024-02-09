import Foundation
import CoreImage

/**
 추적 중인 사각형 물체를 설명합니다.
 
 ```swift
 init(cornerPoints: [CGPoint])
 ```
 - Important: 위 생성자를 사용할 경우, 다음과 같은 배열의 순서로 초기화합니다. [topLeft, topRight, bottomRight, bottomLeft]
 */
struct RectangleModel {
    let topLeft: CGPoint
    let topRight: CGPoint
    let bottomLeft: CGPoint
    let bottomRight: CGPoint
    
    var cornerPoints: [CGPoint] {
        return [topLeft, topRight, bottomRight, bottomLeft]
    }
    
    init(rectangleFeature: CIRectangleFeature) {
        self.topLeft = rectangleFeature.topLeft
        self.topRight = rectangleFeature.topRight
        self.bottomLeft = rectangleFeature.bottomLeft
        self.bottomRight = rectangleFeature.bottomRight
    }
    
    init(topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
    }
    
    init(cornerPoints: [CGPoint]) {
        self.topLeft = cornerPoints[0]
        self.topRight = cornerPoints[1]
        self.bottomRight = cornerPoints[2]
        self.bottomLeft = cornerPoints[3]
    }
    
    func isSimilar(with rectangle: RectangleModel) -> Bool {
        let distanceThreshold: CGFloat = 940
        
        if self.topLeft.distance(to: rectangle.topLeft) > distanceThreshold &&
           self.topRight.distance(to: rectangle.topRight) > distanceThreshold &&
           self.bottomLeft.distance(to: rectangle.bottomLeft) > distanceThreshold &&
           self.bottomRight.distance(to: rectangle.bottomRight) > distanceThreshold {
            return false
        }
        
        return true
    }
}
