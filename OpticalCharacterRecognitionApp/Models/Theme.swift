import UIKit

struct Theme {
    enum Color {
        case primary, secondary
    }
    
    private init() {}
    
    static func paintColor(color: Color, alpha: CGFloat = 1) -> UIColor {
        switch color {
        case .primary:
            UIColor(red: 66/225, green: 171/225, blue: 225/225, alpha: alpha)
        case .secondary:
            UIColor(red: 79/225, green: 84/225, blue: 125/225, alpha: alpha)
        }
    }
}
