import Foundation

enum PhotoCaptureProcessorError: Error, CustomDebugStringConvertible {
    case notEnoughPermission
    case deviceNotFound
    case canNotAddInput
    case canNotAddOutput
    
    var debugDescription: String {
        switch self {
        case .notEnoughPermission:
            "카메라 장치 접근 권한이 없음"
        case .deviceNotFound:
            "적절한 캡처 장치를 찾을 수 없음"
        case .canNotAddInput:
            "Session에 Input을 추가할 수 없음"
        case .canNotAddOutput:
            "Session에 Output을 추가할 수 없음"
        }
    }
}
