import Foundation

enum CameraError: Error, CustomDebugStringConvertible {
    case deviceNotFound
    
    var debugDescription: String {
        switch self {
        case .deviceNotFound:
            "적절한 캡처 장치를 찾을 수 없음"
        }
    }
}
