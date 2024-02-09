import UIKit

final class DocumentCell: UICollectionViewCell {
    // MARK: Properties
    private var document: Document?
    
    // MARK: IBOutlets
    @IBOutlet private weak var documentImageView: UIImageView!
    
    
}

// MARK: Configure Methods
extension DocumentCell {
    func configureCell(with document: Document) {
        self.document = document
    }
}
