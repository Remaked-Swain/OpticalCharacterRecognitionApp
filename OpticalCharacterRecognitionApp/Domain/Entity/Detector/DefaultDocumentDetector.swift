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
            try detectRectangle(on: pixelBuffer)
            return
        }
        try trackRectangle(on: pixelBuffer, detectedObservation: lastObservation)
    }
}

// MARK: Private Methods
extension DefaultDocumentDetector {
    private func detectRectangle(on pixelBuffer: CVPixelBuffer) throws {
        let request = VNDetectRectanglesRequest(completionHandler: handleDetectionRequestUpdate)
        request.minimumAspectRatio = VNAspectRatio(0.6)
        request.maximumAspectRatio = VNAspectRatio(1.0)
        try visionSequenceHandler.perform([request], on: pixelBuffer)
    }
    
    private func trackRectangle(on pixelBuffer: CVPixelBuffer, detectedObservation: VNRectangleObservation) throws {
        let request = VNTrackRectangleRequest(rectangleObservation: detectedObservation, completionHandler: handleDetectionRequestUpdate)
        request.trackingLevel = .accurate
        try visionSequenceHandler.perform([request], on: pixelBuffer)
    }
    
    private func handleDetectionRequestUpdate(_ request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRectangleObservation],
              let newObservation = observations.max(by: { $0.area >= $1.area })
        else {
            invalidateDetectionTimer()
            return
        }
        
        
        lastObservation = newObservation
        
        guard newObservation.confidence >= 0.3 else {
            delegate?.notifyTrackingResult(self, rectangle: nil, error: DetectError.rectangleDetectionFailed)
            invalidateDetectionTimer()
            return
        }
        
        let trackedRectangle = TrackedRectangle(observation: newObservation)
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
        guard detectionTimer != nil else { return }
        detectionTimer?.invalidate()
        detectionTimer = nil
    }
}
