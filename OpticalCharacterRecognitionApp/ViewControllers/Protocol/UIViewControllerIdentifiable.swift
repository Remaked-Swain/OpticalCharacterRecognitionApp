import UIKit

protocol UIViewControllerIdentifiable: UIViewController {
    static var identifier: String { get }
}

extension UIViewControllerIdentifiable {
    static var identifier: String { String(describing: Self.self) }
}
