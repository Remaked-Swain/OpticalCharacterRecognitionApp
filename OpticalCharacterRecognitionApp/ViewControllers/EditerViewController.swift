import UIKit

final class EditerViewController: UIViewController, UIViewControllerIdentifiable {
    // MARK: Dependencies
    private let documentPersistentContainer: DocumentPersistentContainerProtocol
    private let documentDetector: DocumentDetector
    
    // MARK: Properties
    private var editingDocument: Document
    
    // MARK: IBOutlets
    @IBOutlet private weak var documentImageView: DocumentImageView!
    
    init?(coder: NSCoder, documentPersistentContainer: DocumentPersistentContainerProtocol, documentDetector: DocumentDetector, for editingDocument: Document) {
        self.documentPersistentContainer = documentPersistentContainer
        self.documentDetector = documentDetector
        self.editingDocument = editingDocument
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
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: IBActions
    @IBAction private func touchUpCancelButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func touchUpDoneButton(_ sender: UIButton) {
        guard let detectedRectangle = editingDocument.detectedRectangle else { return }
        
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
        documentImageView.delegate = self
        documentImageView.configure(with: editingDocument.image)
    }
}

// MARK: MagneticRectanglePresentationDelegate Confirmation
extension EditerViewController: MagneticRectanglePresentationDelegate {
    func didImageUpdate(_ delegate: DocumentImageView, image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        let ciImage = CIImage(cgImage: cgImage)
        
        do {
            let detectedRectangle = try documentDetector.detect(in: image, viewSize: delegate.bounds.size)
            delegate.updateMagneticRectangleHighlight(detectedRectangle)
            editingDocument = editingDocument.changeDocument(newImage: ciImage, newDetectedRectangle: detectedRectangle)
        } catch {
            editingDocument = editingDocument.changeDocument(newImage: ciImage, newDetectedRectangle: nil)
        }
    }
}
