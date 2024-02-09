import UIKit

final class DocumentCell: UICollectionViewCell, ReusingCellIdentifiable {
    // MARK: IBOutlets
    @IBOutlet private weak var documentImageView: UIImageView!
}

// MARK: Configure Methods
extension DocumentCell {
    func configureCell(with document: Document) {
        let uiImage = UIImage(ciImage: document.image)
        documentImageView.image = uiImage.rotate(by: 90)
    }
}
