import UIKit

final class DocumentPagesViewController: UIViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Document>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Document>
    
    // MARK: Dependencies
    private let documentPersistentContainer: DocumentPersistentContainerProtocol
    
    // MARK: Properties
    private var dataSource: DataSource?
    private var snapshot: Snapshot = Snapshot()
    
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
//        changeNavigationTitle()
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
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<DocumentCell, Document> { cell, indexPath, itemIdentifier in
            cell.configureCell(with: itemIdentifier)
        }
        
        dataSource = DataSource(collectionView: documentCollectionView) { (documentCollectionView, indexPath, itemIdentifier) -> DocumentCell? in
            let cell = documentCollectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            return cell
        }
        
        let allDocuments = documentPersistentContainer.resolve()
        initializeDataSource(with: allDocuments)
    }
}

// MARK: Private Methods
extension DocumentPagesViewController {
    private func changeNavigationTitle(_ index: Int) {
        // TODO: NavigationTitle 바뀌어야됨 스크롤 될떄마다
        navigationItem.title = "\(index + 1)/\(documentPersistentContainer.count)"
    }
}

// MARK: DataSource Controls
extension DocumentPagesViewController {
    private enum Section: Int, CaseIterable {
        case main = 0
        
        var sectionNumber: Int {
            self.rawValue
        }
    }
    
    private func initializeDataSource(with documents: [Document]) {
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(documents)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}
