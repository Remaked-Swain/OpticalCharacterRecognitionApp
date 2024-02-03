import Foundation
import CoreImage
import Vision

protocol VisionTrackerProcessDelegate: AnyObject {
    func notifyTrackingResult(_ delegate: DefaultDocumentDetector, rectangle: TrackedRectangle?, error: Error?)
    func didFinishTracking(_ delegate: DefaultDocumentDetector, isFinish: Bool)
}

final class DefaultDocumentDetector {
    // MARK: Properties
    private var lastObservation: VNRectangleObservation?
    private let visionSequenceHandler: VNSequenceRequestHandler = VNSequenceRequestHandler()
    private var detectionTimer: Timer?
    
    // MARK: Dependencies
    weak var delegate: VisionTrackerProcessDelegate?
    
    // MARK: Interface
    func detect(on pixelBuffer: CVPixelBuffer) throws {
        guard let lastObservation = lastObservation else {
            let request = VNDetectRectanglesRequest(completionHandler: handleDetectionRequestUpdate)
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
            try handler.perform([request])
            return
        }
        try detectRectangleOnPixelBuffer(on: pixelBuffer, detectedObservation: lastObservation)
    }
}

// MARK: Private Methods
extension DefaultDocumentDetector {
    private func detectRectangleOnPixelBuffer(on pixelBuffer: CVPixelBuffer, detectedObservation: VNRectangleObservation) throws {
        let request = VNTrackRectangleRequest(rectangleObservation: detectedObservation, completionHandler: handleDetectionRequestUpdate)
        request.trackingLevel = .accurate
        
        try visionSequenceHandler.perform([request], on: pixelBuffer)
    }
    
    private func handleDetectionRequestUpdate(_ request: VNRequest, error: Error?) {
        guard let newObservation = request.results?.first as? VNRectangleObservation else {
            print("감지 실패 --------- 1")
            invalidateDetectionTimer()
            return
        }
        
        lastObservation = newObservation
        
        guard newObservation.confidence >= 0.3 else {
            print("낮은 신뢰도 --------- 2")
            delegate?.notifyTrackingResult(self, rectangle: nil, error: DetectError.rectangleDetectionFailed)
            invalidateDetectionTimer()
            return
        }
        
        let trackedRectangle = TrackedRectangle(observation: newObservation)
        print("감지 성공 --------- 3")
        delegate?.notifyTrackingResult(self, rectangle: trackedRectangle, error: nil)
        
        setUpDetectionTimer()
    }
    
    private func setUpDetectionTimer() {
        guard detectionTimer == nil else { return }
        
        detectionTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            delegate?.didFinishTracking(self, isFinish: true)
        }
        detectionTimer?.fire()
    }
    
    private func invalidateDetectionTimer() {
        detectionTimer?.invalidate()
        detectionTimer = nil
    }
}
