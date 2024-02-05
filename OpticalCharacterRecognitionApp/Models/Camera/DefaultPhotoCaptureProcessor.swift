import Foundation
import CoreImage
import AVFoundation

protocol CaptureProcessorDelegate: AnyObject {
    func captureOutput(_ delegate: PhotoCaptureProcessor, didOutput pixelBuffer: CVPixelBuffer)
    func captureOutput(_ delegate: PhotoCaptureProcessor, didOutput ciImage: CIImage?, withError error: Error?)
}

protocol PhotoCaptureProcessor: AVCaptureVideoDataOutputSampleBufferDelegate & AVCapturePhotoCaptureDelegate {
    var delegate: CaptureProcessorDelegate? { get set }
    var session: AVCaptureSession { get }
    func checkPermission(completionHandler: @escaping (Bool) -> Void) throws
    func setUpCaptureSession()
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
    
    // MARK: Dependencies
    weak var delegate: CaptureProcessorDelegate?
    
    // MARK: Interface
    func checkPermission(completionHandler: @escaping (Bool) -> Void) throws {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            completionHandler(true)
        case .notDetermined, .restricted, .denied:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completionHandler(granted)
            }
        @unknown default:
            throw CameraError.notEnoughPermission
        }
    }
    
    func setUpCaptureSession() {
        guard session.inputs.isEmpty else { return }
        session.beginConfiguration()
        
        do {
            let videoDevice = try selectCaptureDevice(in: .back)
            addCaptureDeviceInput(device: videoDevice)
            addCaptureDeviceOutput()
            start()
        } catch {
            guard let error = error as? CameraError else {
                return print(error)
            }
            print(error.debugDescription)
        }
    }
    
    func capture() {
        let settings = AVCapturePhotoSettings()
        settings.photoQualityPrioritization = .balanced
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func start() {
        guard session.isRunning == false else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
        }
    }
    
    func stop() {
        guard session.isRunning == true else { return }
        session.stopRunning()
    }
}

// MARK: Private Methods
extension DefaultPhotoCaptureProcessor {
    private func selectCaptureDevice(in position: AVCaptureDevice.Position) throws -> AVCaptureDevice {
        let deviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInDualCamera, .builtInTripleCamera, .builtInTelephotoCamera, .builtInWideAngleCamera
        ]
        
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes,
                                                                mediaType: .video,
                                                                position: position)
        
        guard discoverySession.devices.isEmpty == false,
              let device = discoverySession.devices.first(where: { $0.position == position })
        else {
            throw CameraError.deviceNotFound
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
        
        if session.canSetSessionPreset(.hd1280x720) {
            session.sessionPreset = .hd1280x720
        }
        if session.canSetSessionPreset(.hd1920x1080) {
            session.sessionPreset = .hd1920x1080
        }
        if session.canSetSessionPreset(.hd4K3840x2160) {
            session.sessionPreset = .hd4K3840x2160
        }
        setUpVideoOutput()
        session.addOutput(photoOutput)
        session.addOutput(videoOutput)
        session.commitConfiguration()
    }
    
    private func setUpVideoOutput() {
        videoOutput.setSampleBufferDelegate(self, queue: sampleBufferQueue)
    }
}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate Confirmation
extension DefaultPhotoCaptureProcessor: AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        delegate?.captureOutput(self, didOutput: pixelBuffer)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let pixelBuffer = photo.pixelBuffer else {
            delegate?.captureOutput(self, didOutput: nil, withError: error)
            return
        }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        delegate?.captureOutput(self, didOutput: ciImage, withError: nil)
    }
}
