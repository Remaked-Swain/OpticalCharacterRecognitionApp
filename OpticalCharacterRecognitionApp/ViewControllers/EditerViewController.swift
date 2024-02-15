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
    
    override func viewDidAppear(_ animated: Bool) {
        magnet(on: documentImageView)
    }
    
    // MARK: IBActions
    @IBAction private func touchUpCancelButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func touchUpDoneButton(_ sender: UIButton) {
        extractImage(on: documentImageView)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: Configure Methods
extension EditerViewController {
    private func configureDocumentImageView() {
        documentImageView.configure(with: editingDocument.image)
    }
}

// MARK: Private Methods
extension EditerViewController {
    private func changeDocument(with document: Document, newImage: CIImage? = nil, newDetectedRectangle: RectangleModel? = nil) -> Document {
        let newDocument = Document(id: document.id,
                                   image: newImage ?? document.image,
                                   detectedRectangle: newDetectedRectangle ?? document.detectedRectangle)
        return newDocument
    }
    
    private func magnet(on imageView: DocumentImageView) {
        guard let cgImage = imageView.image?.cgImage else { return }
        let ciImage = CIImage(cgImage: cgImage)
        
        do {
            let detectedRectangle = try documentDetector.detect(in: ciImage, forType: .general)
            let transformedRectangle = convertRectangleCoordinatesSpace(detectedRectangle, originImageRect: ciImage.extent, viewSize: imageView.bounds.size)
            imageView.updateMagneticRectangleHighlight(transformedRectangle)
            editingDocument = changeDocument(with: editingDocument, newImage: ciImage, newDetectedRectangle: detectedRectangle)
        } catch {
            editingDocument = changeDocument(with: editingDocument, newImage: ciImage, newDetectedRectangle: nil)
        }
    }
    
    private func extractImage(on imageView: DocumentImageView) {
        guard let cgImage = imageView.image?.cgImage else { return }
        let ciImage = CIImage(cgImage: cgImage)
        
        let rectangle = RectangleModel(cornerPoints: imageView.highlightArea)
        let filteredImage = documentDetector.filter(filterType: .perspectiveCorrection, image: ciImage, rectangle: rectangle)
        let document = changeDocument(with: editingDocument, newImage: filteredImage, newDetectedRectangle: rectangle)
        documentPersistentContainer.store(document: document)
    }
    
    private func convertRectangleCoordinatesSpace(_ rectangle: RectangleModel, originImageRect rect: CGRect, viewSize: CGSize) -> RectangleModel {
        let imageWidth = rect.width
        let imageHeight = rect.height
        
        let scaleX = viewSize.width / imageWidth
        let scaleY = viewSize.height / imageHeight
        
        let cornerPoints = rectangle.cornerPoints.map { $0.flipPositionY(scaleX, scaleY, displayTargetHeight: viewSize.height) }
        return RectangleModel(cornerPoints: cornerPoints)
    }
}
