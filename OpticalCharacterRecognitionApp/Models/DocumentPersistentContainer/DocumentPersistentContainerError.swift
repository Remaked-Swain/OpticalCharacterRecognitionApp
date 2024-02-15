import Foundation

enum DocumentPersistentContainerError: Error, CustomDebugStringConvertible {
    case documentNotFound
    case indexOutOfRange
    
    var debugDescription: String {
        switch self {
        case .documentNotFound:
            "요청한 문서가 존재하지 않습니다."
        case .indexOutOfRange:
            "문서에 대하여 범위를 벗어난 요청입니다."
        }
    }
}
