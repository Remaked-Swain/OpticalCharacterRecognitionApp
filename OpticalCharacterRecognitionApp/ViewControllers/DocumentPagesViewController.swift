import UIKit

final class DocumentPagesViewController: UIViewController, UIViewControllerIdentifiable {
    // MARK: Dependencies
    private let documentPersistentContainer: DocumentPersistentContainerProtocol
    
    // MARK: IBOutlets
    @IBOutlet private weak var documentCollectionView: UICollectionView!
    
    init?(coder: NSCoder, documentPersistentContainer: DocumentPersistentContainerProtocol) {
        self.documentPersistentContainer = documentPersistentContainer
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureDocumentCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let lastDocumentIndex = documentPersistentContainer.count - 1
        let indexPath = IndexPath(item: lastDocumentIndex, section: .zero)
        documentCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
        changeNavigationTitle(lastDocumentIndex)
    }
    
    // MARK: IBActions
    @IBAction private func touchUpTrashButton(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction private func touchUpReversedClockButton(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction private func touchUpComposeButton(_ sender: UIBarButtonItem) {
        
    }
}

// MARK: Configure Methods
extension DocumentPagesViewController {
    private func configureDocumentCollectionView() {
        documentCollectionView.delegate = self
        documentCollectionView.dataSource = self
        documentCollectionView.isPagingEnabled = true
        documentCollectionView.showsHorizontalScrollIndicator = false
        documentCollectionView.backgroundColor = .white
    }
}

// MARK: Private Methods
extension DocumentPagesViewController {
    private func changeNavigationTitle(_ index: Int) {
        navigationItem.title = "\(index + 1)/\(documentPersistentContainer.count)"
    }
}

// MARK: UICollectionViewDataSource & UICollectionViewDelegateFlowLayout
extension DocumentPagesViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return documentPersistentContainer.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DocumentCell.reuseIdentifier, for: indexPath) as? DocumentCell else {
            return DocumentCell()
        }
        let document = documentPersistentContainer.resolve(for: indexPath.row)
        cell.configureCell(with: document)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        changeNavigationTitle(indexPath.row)
    }
}
