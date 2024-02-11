import UIKit

struct Theme {
    enum Color {
        case main, sub
        
        var name: String {
            switch self {
            case .main: "MainColor"
            case .sub: "SubColor"
            }
        }
    }
    
    private init() {}
    
    static func paintCGColor(_ type: Color, alpha: CGFloat = 1) -> CGColor? {
        let uiColor = UIColor(named: type.name)
        return uiColor?.withAlphaComponent(alpha).cgColor
    }
    
    static func paintUIColor(_ type: Color, alpha: CGFloat = 1) -> UIColor? {
        let uiColor = UIColor(named: type.name)
        return uiColor?.withAlphaComponent(alpha)
    }
}
