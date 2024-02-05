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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        photoCaptureProcessor.delegate = self
        detector.delegate = self
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
    @IBAction func touchUpPreviewerButton(_ sender: UIButton) {
        
    }
}

// MARK: CaptureProcessorDelegate Confirmation
extension ScannerViewController: CaptureProcessorDelegate {
    func captureOutput(_ delegate: PhotoCaptureProcessor, didOutput pixelBuffer: CVPixelBuffer) {
        detector.detect(on: pixelBuffer)
    }
    
    func captureOutput(_ delegate: PhotoCaptureProcessor, didOutput ciImage: CIImage?, withError error: Error?) {
        
    }
}

// MARK: VisionTrackerProcessDelegate Confirmation
extension ScannerViewController: DetectingProcessDelegate {
    func notifyDetectingResult(_ delegate: DefaultDocumentDetector, rectangle: TrackedRectangle?, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            self?.videoView.trackedRectangle = rectangle
        }
    }
    
    func didFinishTracking(_ delegate: DefaultDocumentDetector) {
        photoCaptureProcessor.capture()
        photoCaptureProcessor.stop()
    }
}
