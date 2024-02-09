import UIKit
import AVFoundation

final class ScannerViewController: UIViewController {
    // MARK: Dependencies
    private let photoCaptureProcessor: PhotoCaptureProcessor = DefaultPhotoCaptureProcessor()
    private let detector: DocumentDetector = DefaultDocumentDetector()
    
    // MARK: IBOutlets
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var captureModeButton: UIButton!
    @IBOutlet private weak var videoView: VideoView!
    @IBOutlet private weak var takeCaptureButton: UIButton!
    @IBOutlet private weak var saveCaptureButton: UIButton!
    @IBOutlet private weak var preImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        photoCaptureProcessor.delegate = self
        configurePhotoCaptureProcessor()
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
            videoView.session = photoCaptureProcessor.session
            photoCaptureProcessor.start()
        } catch {
            guard let error = error as? PhotoCaptureProcessorError else {
                print(error)
                return
            }
            print(error)
        }
    }
    
    private func configurePreImageView() {
        preImageView.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pushEditerViewController))
        
        
    }
}

// MARK: CaptureProcessorDelegate Confirmation
extension ScannerViewController: CaptureProcessorDelegate {
    func captureOutput(_ delegate: PhotoCaptureProcessor, didOutput pixelBuffer: CVPixelBuffer) {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        do {
            let trackedRectangle = try detector.detect(in: ciImage)
            
            DispatchQueue.main.async { [weak self] in
                self?.videoView.updateRectangleOverlay(trackedRectangle, originImageRect: ciImage.extent)
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
            let trackedRectangle = try detector.detect(in: ciImage)
            let uiImage = UIImage(ciImage: ciImage)
            
            DispatchQueue.main.async { [weak self] in
                self?.preImageView.image = uiImage.rotate(by: 90)
            }
        } catch {
            guard let error = error as? DetectError else { return }
            print(error)
        }
    }
}

// MARK: Private Methods
extension ScannerViewController {
    @objc private func pushEditerViewController() {
        
    }
}
