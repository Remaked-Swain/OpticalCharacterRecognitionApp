import Foundation

enum CameraError: Error, CustomDebugStringConvertible {
    case notEnoughPermission
    case deviceNotFound
    
    var debugDescription: String {
        switch self {
        case .notEnoughPermission:
            "카메라 장치 접근 권한이 없음"
        case .deviceNotFound:
            "적절한 캡처 장치를 찾을 수 없음"
        }
    }
}
