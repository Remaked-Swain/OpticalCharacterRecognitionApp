import UIKit

struct Theme {
    enum Color {
        case primary, secondary
    }
    
    private init() {}
    
    static func paintColor(color: Color, alpha: CGFloat = 1) -> UIColor {
        switch color {
        case .primary:
            UIColor(red: 66, green: 171, blue: 225, alpha: alpha)
        case .secondary:
            UIColor(red: 79, green: 84, blue: 125, alpha: alpha)
        }
    }
}
