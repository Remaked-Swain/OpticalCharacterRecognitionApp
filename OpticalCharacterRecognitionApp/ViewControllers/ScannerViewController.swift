import UIKit
import AVFoundation

final class ScannerViewController: UIViewController {
    // MARK: Dependencies
    private let photoCaptureProcessor: PhotoCaptureProcessor = DefaultPhotoCaptureProcessor()
    private let detector: DocumentDetector = DefaultDocumentDetector()
    private let documentPersistentContainer: DocumentPersistentContainerProtocol = DocumentPersistentContainer()
    private let filter: FilterProtocol = Filter()
    
    // MARK: IBOutlets
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var captureModeButton: CaptureModeButton!
    @IBOutlet private weak var videoView: VideoView!
    @IBOutlet private weak var documentPreview: UIImageView!
    @IBOutlet private weak var takeCaptureButton: UIButton!
    @IBOutlet private weak var saveCaptureButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        photoCaptureProcessor.delegate = self
        configurePhotoCaptureProcessor()
        captureModeButton.configureCaptureButton()
        configureDocumentPreview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        videoView.session = photoCaptureProcessor.session
        photoCaptureProcessor.start()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        photoCaptureProcessor.stop()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoView.videoPreviewLayer.frame = videoView.bounds
    }
    
    // MARK: IBActions
    @IBAction private func touchUpCancelButton(_ sender: UIButton) {
        if photoCaptureProcessor.session.isRunning {
            photoCaptureProcessor.stop()
        } else {
            photoCaptureProcessor.start()
        }
    }
    
    @IBAction private func touchUpCaptureModeButton(_ sender: UIButton) {
        captureModeButton.toggleCaptureMode()
    }
    
    @IBAction private func touchUpTakeCaptureButton(_ sender: UIButton) {
        photoCaptureProcessor.capture()
    }
    
    @IBAction private func touchUpSaveCaptureButton(_ sender: UIButton) {
        
    }
}

// MARK: Configure Methods
extension ScannerViewController {
    private func configurePhotoCaptureProcessor() {
        do {
            try photoCaptureProcessor.setUpCaptureProcessor()
        } catch {
            guard let error = error as? PhotoCaptureProcessorError else {
                print(error)
                return
            }
            print(error)
        }
    }
    
    private func configureDocumentPreview() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pushDocumentPagesViewController))
        documentPreview.isUserInteractionEnabled = true
        documentPreview.addGestureRecognizer(tapGestureRecognizer)
        documentPreview.contentMode = .scaleAspectFill
    }
}

// MARK: CaptureProcessorDelegate Confirmation
extension ScannerViewController: CaptureProcessorDelegate {
    func captureOutput(_ delegate: PhotoCaptureProcessor, didOutput pixelBuffer: CVPixelBuffer) {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        do {
            let detectedRectangle = try detector.detect(in: ciImage)
            
            DispatchQueue.main.async { [weak self] in
                self?.videoView.updateRectangleOverlay(detectedRectangle, originImageRect: ciImage.extent)
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.videoView.removeRectangleOverlay()
            }
        }
    }
    
    func captureOutput(_ delegate: PhotoCaptureProcessor, didOutput ciImage: CIImage?, withError error: Error?) {
        guard let ciImage = ciImage else { return }
        
        do {
            let detectedRectangle = try detector.detect(in: ciImage)
            let filteredImage = filter.filter(filterType: .perspectiveCorrection, image: ciImage, rectangle: detectedRectangle)
            let document = Document(image: filteredImage, detectedRectangle: detectedRectangle)
            storeDocument(document: document)
        } catch {
            switch error {
            case DetectError.rectangleDetectionFailed:
                let document = Document(image: ciImage, detectedRectangle: nil)
                storeDocument(document: document)
            default:
                print("Unknown Error on \(self)")
            }
        }
    }
}

// MARK: Private Methods
extension ScannerViewController {
    @objc private func pushDocumentPagesViewController() {
        if let documentPagesViewController = storyboard?.instantiateViewController(identifier: "DocumentPagesViewController", creator: { coder in
            DocumentPagesViewController(coder: coder, documentPersistentContainer: self.documentPersistentContainer)
        }) {
            navigationController?.pushViewController(documentPagesViewController, animated: true)
        }
    }
    
    private func storeDocument(document: Document) {
        documentPersistentContainer.store(document: document)
        
        let uiImage = UIImage(ciImage: document.image)
        DispatchQueue.main.async { [weak self] in
            self?.documentPreview.image = uiImage.rotate(by: 90)
        }
    }
}
