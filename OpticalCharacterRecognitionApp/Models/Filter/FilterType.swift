import CoreImage

enum FilterType {
    case perspectiveCorrection
    
    var name: String {
        switch self {
        case .perspectiveCorrection:
            "CIPerspectiveCorrection"
        }
    }
}
