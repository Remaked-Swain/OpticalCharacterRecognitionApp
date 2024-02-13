import UIKit

protocol ReusingCellIdentifiable: UICollectionViewCell {
    static var reuseIdentifier: String { get }
}

extension ReusingCellIdentifiable {
    static var reuseIdentifier: String { String(describing: self.self) }
}
