import UIKit

final class EditerViewController: UIViewController, UIViewControllerIdentifiable {
    // MARK: Dependencies
    private let documentPersistentContainer: DocumentPersistentContainerProtocol
    private let documentDetector: DocumentDetector
    
    // MARK: Properties
    private var editingDocument: Document?
    
    // MARK: IBOutlets
    @IBOutlet private weak var documentImageView: DocumentImageView!
    
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
        configureDocumentImageView()
    }
    
    // MARK: IBActions
    @IBAction private func touchUpCancelButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func touchUpDoneButton(_ sender: UIButton) {
        guard let editingDocument = editingDocument,
              let detectedRectangle = editingDocument.detectedRectangle
        else { return }
        
        let editingImage = editingDocument.image
        let filteredImage = documentDetector.filter(filterType: .perspectiveCorrection, image: editingImage, rectangle: detectedRectangle)
        let document = editingDocument.changeDocument(newImage: filteredImage, newDetectedRectangle: detectedRectangle)
        documentPersistentContainer.store(document: document)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: Configure Methods
extension EditerViewController {
    private func configureDocumentImageView() {
        let lastDocumentIndex = documentPersistentContainer.count - 1
        guard let document = try? documentPersistentContainer.fetch(for: lastDocumentIndex) else {
            print("Fetching Document Failed")
            return
        }
        
        editingDocument = document
        documentImageView.delegate = self
        documentImageView.configure(with: document.image)
    }
}

// MARK: MagneticRectanglePresentationDelegate Confirmation
extension EditerViewController: MagneticRectanglePresentationDelegate {
    func didHighlightAreaUpdate(_ delegate: DocumentImageView, imageInArea ciImage: CIImage) {
        guard let detectedRectangle = try? documentDetector.detect(in: ciImage) else {
            editingDocument = editingDocument?.changeDocument(newDetectedRectangle: nil)
            return
        }
        
        documentImageView.updateMagneticRectangleHighlight(detectedRectangle)
        editingDocument = editingDocument?.changeDocument(newImage: ciImage, newDetectedRectangle: detectedRectangle)
    }
}
