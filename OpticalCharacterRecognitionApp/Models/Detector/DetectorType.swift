import CoreImage

enum DetectorType {
    case general
    case businessCard
    
    var options: [String: Any] {
        switch self {
        case .general:
            [
                CIDetectorAccuracy: CIDetectorAccuracyHigh
            ]
        case .businessCard:
            [
                CIDetectorAccuracy: CIDetectorAccuracyHigh,
                CIDetectorAspectRatio: 1.75
            ]
        }
    }
}
