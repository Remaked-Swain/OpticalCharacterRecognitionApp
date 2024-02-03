import Foundation

enum ResolutionType {
    case HD, fullHD, quadHD
    
    var dimension: (width: Int32, height: Int32) {
        switch self {
        case .HD:
            (1280, 720)
        case .fullHD:
            (1920, 1080)
        case .quadHD:
            (2560, 1440)
        }
    }
}
