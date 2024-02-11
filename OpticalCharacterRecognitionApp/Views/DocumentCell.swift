import UIKit

final class DocumentCell: UICollectionViewCell, ReusingCellIdentifiable {
    // MARK: IBOutlets
    @IBOutlet private weak var documentImageView: UIImageView!
}

// MARK: Configure Methods
extension DocumentCell {
    func configureCell(with document: Document) {
        documentImageView.contentMode = .scaleAspectFit
        let uiImage = UIImage(ciImage: document.image)
        documentImageView.image = uiImage.rotate()
    }
}
