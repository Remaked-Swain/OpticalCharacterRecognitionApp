import UIKit
import CoreImage
import AVFoundation

protocol CaptureProcessorDelegate: AnyObject {
    func captureOutput(_ delegate: PhotoCaptureProcessor, didOutput pixelBuffer: CVPixelBuffer)
    func captureOutput(_ delegate: PhotoCaptureProcessor, didOutput ciImage: CIImage?, withError error: Error?)
}

protocol PhotoCaptureProcessor: AVCaptureVideoDataOutputSampleBufferDelegate & AVCapturePhotoCaptureDelegate {
    var delegate: CaptureProcessorDelegate? { get set }
    func setUpCaptureProcessor() throws
    func capture()
    func start()
    func stop()
}

final class DefaultPhotoCaptureProcessor: NSObject, PhotoCaptureProcessor {
    // MARK: Properties
    private let session: AVCaptureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sampleBufferQueue = DispatchQueue.global(qos: .userInteractive)
    
    // MARK: Dependencies
    weak var delegate: CaptureProcessorDelegate?
    
    // MARK: Interface
    func setUpCaptureProcessor() throws {
        try requestPermission()
        try setUpCaptureSession()
    }
    
    func capture() {
        let settings = AVCapturePhotoSettings()
        settings.photoQualityPrioritization = .balanced
        
        if let connection = photoOutput.connection(with: .video) {
            connection.videoOrientation = AVCaptureVideoOrientation(deviceOrientation: UIDevice.current.orientation) ?? .portrait
        }
        
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
        var permitted: Bool = false
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            permitted = true
        case .notDetermined, .restricted:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                permitted = granted
            }
        default:
            throw PhotoCaptureProcessorError.notEnoughPermission
        }
        
        guard permitted else {
            throw PhotoCaptureProcessorError.notEnoughPermission
        }
    }
    
    private func setUpCaptureSession() throws {
        session.beginConfiguration()
        setUpSessionPreset()
        
        let videoDevice = try selectCaptureDevice(in: .back)
        addCaptureDeviceInput(device: videoDevice)
        addCaptureDeviceOutput()
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
    
    private func addCaptureDeviceInput(device: AVCaptureDevice) {
        guard let cameraInput = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(cameraInput)
        else { return }
        session.addInput(cameraInput)
    }
    
    private func addCaptureDeviceOutput() {
        guard session.canAddOutput(photoOutput),
              session.canAddOutput(videoOutput)
        else { return }
        
        session.addOutput(photoOutput)
        session.addOutput(videoOutput)
        session.commitConfiguration()
    }
}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate Confirmation
extension DefaultPhotoCaptureProcessor: AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        if let connection = output.connection(with: .video) {
            connection.videoOrientation = AVCaptureVideoOrientation(deviceOrientation: UIDevice.current.orientation) ?? .portrait
        }
        
        delegate?.captureOutput(self, didOutput: pixelBuffer)
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
