import UIKit

enum Theme {
    case primary(alpha: CGFloat), secondary(alpha: CGFloat)
    
    var color: UIColor {
        switch self {
        case .primary(let alpha):
            UIColor(red: 66, green: 171, blue: 225, alpha: alpha)
        case .secondary(let alpha):
            UIColor(red: 79, green: 84, blue: 125, alpha: alpha)
        }
    }
}
