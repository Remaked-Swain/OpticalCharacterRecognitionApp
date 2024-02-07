import UIKit

struct Theme {
    enum Color {
        case primary, secondary
    }
    
    private init() {}
    
    static func paintColor(_ type: Color, alpha: CGFloat = 1) -> CGColor {
        switch type {
        case .primary:
            CGColor(red: 66/225, green: 171/225, blue: 225/225, alpha: alpha)
        case .secondary:
            CGColor(red: 79/225, green: 84/225, blue: 125/225, alpha: alpha)
        }
    }
}
