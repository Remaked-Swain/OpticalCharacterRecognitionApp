import Foundation

enum DetectError: Error, CustomDebugStringConvertible {
    case rectangleDetectionFailed
    
    var debugDescription: String {
        switch self {
        case .rectangleDetectionFailed:
            "사각형 감지 실패"
        }
    }
}
