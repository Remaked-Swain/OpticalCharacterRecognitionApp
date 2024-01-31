import Foundation

enum DetectError: Error, CustomDebugStringConvertible {
    case imageNotFound
    case filterNotFound
    case detectFailed
    
    var debugDescription: String {
        switch self {
        case .imageNotFound:
            "이미지를 찾을 수 없음"
        case .filterNotFound:
            "필터를 찾을 수 없음"
        case .detectFailed:
            "탐지 실패"
        }
    }
}
