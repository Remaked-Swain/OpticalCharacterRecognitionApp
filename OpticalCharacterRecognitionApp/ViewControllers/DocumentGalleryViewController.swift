import UIKit

final class DocumentGalleryViewController: UIViewController, UIViewControllerIdentifiable {
    // MARK: Dependencies
    private let documentPersistentContainer: DocumentPersistentContainerProtocol
    private let documentDetector: DocumentDetector
    
    // MARK: Properties
    private var displayingDocumentIndex: IndexPath?
    
    // MARK: IBOutlets
    @IBOutlet private weak var documentCollectionView: UICollectionView!
    
    init?(coder: NSCoder, documentPersistentContainer: DocumentPersistentContainerProtocol, documentDetector: DocumentDetector) {
        self.documentPersistentContainer = documentPersistentContainer
        self.documentDetector = documentDetector
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
        navigationController?.navigationBar.isHidden = false
        let lastDocumentIndex = documentPersistentContainer.count - 1
        let indexPath = IndexPath(item: lastDocumentIndex, section: .zero)
        documentCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
        changeNavigationTitle(index: lastDocumentIndex)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.navigationItem.title = nil
    }
    
    // MARK: IBActions
    @IBAction private func touchUpTrashButton(_ sender: UIButton) {
        guard let indexPath = displayingDocumentIndex else { return }
        documentPersistentContainer.delete(at: indexPath.row)
        documentCollectionView.deleteItems(at: [indexPath])
        documentCollectionView.reloadData()
    }
    
    @IBAction private func touchUpReversedClockButton(_ sender: UIButton) {
        
    }
    
    @IBAction private func touchUpComposeButton(_ sender: UIButton) {
        if let index = displayingDocumentIndex?.row, let documentForEdit = try? documentPersistentContainer.fetch(for: index) {
            pushEditerViewController(with: documentForEdit)
        }
    }
}

// MARK: Configure Methods
extension DocumentGalleryViewController {
    private func configureDocumentCollectionView() {
        documentCollectionView.delegate = self
        documentCollectionView.dataSource = self
        documentCollectionView.isPagingEnabled = true
        documentCollectionView.showsHorizontalScrollIndicator = false
        documentCollectionView.backgroundColor = .white
    }
}

// MARK: UICollectionViewDataSource & UICollectionViewDelegateFlowLayout
extension DocumentGalleryViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return documentPersistentContainer.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DocumentCell.reuseIdentifier, for: indexPath) as? DocumentCell else {
            return DocumentCell()
        }
        
        if let document = try? documentPersistentContainer.fetch(for: indexPath.row) {
            cell.configureCell(with: document)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        changeNavigationTitle(index: indexPath.row)
        displayingDocumentIndex = indexPath
    }
}

// MARK: Private Methods
extension DocumentGalleryViewController {
    private func changeNavigationTitle(index: Int) {
        guard documentPersistentContainer.isEmpty == false else {
            navigationItem.title = "갤러리가 비어있습니다."
            return
        }
        navigationItem.title = "\(index + 1)/\(documentPersistentContainer.count)"
    }
    
    private func pushEditerViewController(with documentForEdit: Document) {
        if let editerViewController = storyboard?.instantiateViewController(identifier: EditerViewController.identifier, creator: { coder in
            EditerViewController(coder: coder, documentPersistentContainer: self.documentPersistentContainer, documentDetector: self.documentDetector, for: documentForEdit)
        }) {
            navigationController?.pushViewController(editerViewController, animated: true)
        }
    }
}
