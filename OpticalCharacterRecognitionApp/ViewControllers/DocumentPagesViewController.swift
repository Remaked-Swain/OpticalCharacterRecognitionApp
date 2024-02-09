import UIKit

final class DocumentPagesViewController: UIViewController {
    private let photoPersistentContainer: PersistentContainerProtocol
    
    init?(coder: NSCoder, photoPersistentContainer: PersistentContainerProtocol) {
        self.photoPersistentContainer = photoPersistentContainer
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
