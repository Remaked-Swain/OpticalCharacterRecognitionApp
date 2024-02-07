import UIKit
import AVFoundation

final class ScannerViewController: UIViewController {
    // MARK: Dependencies
    private let motionDetector: MotionDetectable = MotionDetector()
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
        videoView.session = photoCaptureProcessor.session
        
        do {
            try photoCaptureProcessor.checkPermission { [weak self] granted in
                if granted {
                    self?.photoCaptureProcessor.setUpCaptureSession()
                }
            }
        } catch {
            guard let error = error as? CameraError else { return }
            print(error.debugDescription)
        }
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

// MARK: CaptureProcessorDelegate Confirmation
extension ScannerViewController: CaptureProcessorDelegate {
    func captureOutput(_ delegate: PhotoCaptureProcessor, didOutput pixelBuffer: CVPixelBuffer) {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let transformedImage = transformImage(ciImage)
        guard let trackedRectangle = detector.detect(in: transformedImage) else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.videoView.updateRectangleOverlay(trackedRectangle, originImageRect: ciImage.extent)
        }
    }
    
    func captureOutput(_ delegate: PhotoCaptureProcessor, didOutput ciImage: CIImage?, withError error: Error?) {
        guard let ciImage = ciImage else { return }
        let uiImage = UIImage(ciImage: ciImage)
        
        preImageView.image = uiImage
    }
}

// MARK: Private Methods
extension ScannerViewController {
    private func transformImage(_ ciImage: CIImage) -> CIImage {
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -ciImage.extent.height)
        let transformedCIImage = ciImage.transformed(by: transform)
        return transformedCIImage
    }
}
