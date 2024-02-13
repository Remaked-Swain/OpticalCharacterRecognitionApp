import UIKit
import CoreImage
import AVFoundation

protocol CaptureProcessorDelegate: AnyObject {
    func captureOutput(_ delegate: PhotoCaptureProcessor, didOutput pixelBuffer: CVPixelBuffer)
    func captureOutput(_ delegate: PhotoCaptureProcessor, didOutput ciImage: CIImage?, withError error: Error?)
}

protocol PhotoCaptureProcessor: AVCaptureVideoDataOutputSampleBufferDelegate & AVCapturePhotoCaptureDelegate {
    var session: AVCaptureSession { get }
    var delegate: CaptureProcessorDelegate? { get set }
    func setUpCaptureProcessor() throws
    func capture()
    func start()
    func stop()
}

final class DefaultPhotoCaptureProcessor: NSObject, PhotoCaptureProcessor {
    // MARK: Properties
    let session: AVCaptureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sampleBufferQueue = DispatchQueue.global(qos: .userInteractive)
    private let frameCountLimit: Int = 10
    private var frameCount = 0
    
    // MARK: Dependencies
    weak var delegate: CaptureProcessorDelegate?
    
    // MARK: Interface
    func setUpCaptureProcessor() throws {
        try requestPermission()
        
        session.beginConfiguration()
        setUpSessionPreset()
        let videoDevice = try selectCaptureDevice(in: .back)
        try addCaptureDeviceInput(device: videoDevice)
        try addCaptureDeviceOutput()
        session.commitConfiguration()
        
        if let connection = videoOutput.connection(with: .video) {
            connection.videoOrientation = .portrait
        }
    }
    
    func capture() {
        let settings = AVCapturePhotoSettings()
        settings.photoQualityPrioritization = .balanced
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func start() {
        guard session.isRunning == false else { return }
        videoOutput.setSampleBufferDelegate(self, queue: sampleBufferQueue)
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }
    
    func stop() {
        guard session.isRunning == true else { return }
        videoOutput.setSampleBufferDelegate(nil, queue: nil)
        session.stopRunning()
    }
}

// MARK: Private Methods
extension DefaultPhotoCaptureProcessor {
    private func requestPermission() throws {
        var isPermitted: Bool = false
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            isPermitted = true
        case .notDetermined, .restricted:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                isPermitted = granted
            }
        default:
            throw PhotoCaptureProcessorError.notEnoughPermission
        }
        
        guard isPermitted else {
            throw PhotoCaptureProcessorError.notEnoughPermission
        }
    }
    
    private func setUpSessionPreset() {
        if session.canSetSessionPreset(.hd1280x720) {
            session.sessionPreset = .hd1280x720
        }
        if session.canSetSessionPreset(.hd1920x1080) {
            session.sessionPreset = .hd1920x1080
        }
        if session.canSetSessionPreset(.hd4K3840x2160) {
            session.sessionPreset = .hd4K3840x2160
        }
    }
    
    private func selectCaptureDevice(in position: AVCaptureDevice.Position) throws -> AVCaptureDevice {
        let deviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInDualCamera, .builtInTripleCamera, .builtInWideAngleCamera,
        ]
        
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes,
                                                                mediaType: .video,
                                                                position: position)
        
        guard discoverySession.devices.isEmpty == false,
              let device = discoverySession.devices.first(where: { $0.position == position })
        else {
            throw PhotoCaptureProcessorError.deviceNotFound
        }
        
        return device
    }
    
    private func addCaptureDeviceInput(device: AVCaptureDevice) throws {
        let input = try AVCaptureDeviceInput(device: device)
        guard session.canAddInput(input) else {
            throw PhotoCaptureProcessorError.canNotAddInput
        }
        session.addInput(input)
    }
    
    private func addCaptureDeviceOutput() throws {
        guard session.canAddOutput(photoOutput),
              session.canAddOutput(videoOutput)
        else {
            throw PhotoCaptureProcessorError.canNotAddOutput
        }
        
        session.addOutput(photoOutput)
        session.addOutput(videoOutput)
    }
}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate Confirmation
extension DefaultPhotoCaptureProcessor: AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        guard frameCount >= frameCountLimit else {
            frameCount += 1
            return
        }
        delegate?.captureOutput(self, didOutput: pixelBuffer)
        frameCount = .zero
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let ciImage = CIImage(data: data)
        else {
            delegate?.captureOutput(self, didOutput: nil, withError: error)
            return
        }
        delegate?.captureOutput(self, didOutput: ciImage, withError: nil)
    }
}
