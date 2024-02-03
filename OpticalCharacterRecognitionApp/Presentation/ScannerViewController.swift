import UIKit
import AVFoundation

final class ScannerViewController: UIViewController {
    // MARK: Dependencies
    private lazy var photoCaptureProcessor: PhotoCaptureProcessor = {
        let processor = DefaultPhotoCaptureProcessor()
        processor.delegate = self
        return processor
    }()
    private let detector: DefaultDocumentDetector = DefaultDocumentDetector()
    
    // MARK: IBOutlets
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var captureModeButton: UIButton!
    @IBOutlet private weak var videoView: VideoView!
    @IBOutlet private weak var takeCaptureButton: UIButton!
    @IBOutlet private weak var saveCaptureButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        videoView.session = photoCaptureProcessor.session
        
        Task {
            guard await photoCaptureProcessor.checkPermission() else { return }
            photoCaptureProcessor.setUpCaptureSession()
        }
    }
    
    // MARK: IBActions
    @IBAction private func touchUpCancelButton(_ sender: UIButton) {
        photoCaptureProcessor.stop()
    }
    @IBAction private func touchUpCaptureModeButton(_ sender: UIButton) {
        
    }
    @IBAction private func touchUpTakeCaptureButton(_ sender: UIButton) {
        photoCaptureProcessor.capture()
    }
    @IBAction private func touchUpSaveCaptureButton(_ sender: UIButton) {
        
    }
    @IBAction func touchUpPreviewerButton(_ sender: UIButton) {
        
    }
}

// MARK: CaptureProcessorDelegate Confirmation
extension ScannerViewController: CaptureProcessorDelegate {
    func captureOutput(_ delegate: PhotoCaptureProcessor, didOutput pixelBuffer: CVPixelBuffer) {
        do {
            try detector.detect(on: pixelBuffer)
        } catch {
            videoView.trackedRectangle = nil
        }
    }
}

// MARK: VisionTrackerProcessDelegate Confirmation
extension ScannerViewController: VisionTrackerProcessDelegate {
    func notifyTrackingResult(_ delegate: DefaultDocumentDetector, rectangle: TrackedRectangle?, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            self?.videoView.trackedRectangle = rectangle
        }
    }
    
    func didFinishTracking(_ delegate: DefaultDocumentDetector, isFinish: Bool) {
//        photoCaptureProcessor.capture()
        photoCaptureProcessor.stop()
    }
}
