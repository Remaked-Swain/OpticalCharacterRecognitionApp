import Foundation
import CoreImage
import AVFoundation

protocol CaptureProcessorDelegate: AnyObject {
    func captureOutput(_ delegate: PhotoCaptureProcessor, didOutput pixelBuffer: CVPixelBuffer)
}

protocol PhotoCaptureProcessor {
    var delegate: CaptureProcessorDelegate? { get set }
    var session: AVCaptureSession { get }
    func checkPermission() async -> Bool
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
    func checkPermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        var isAuthorized: Bool = false
        
        switch status {
        case .authorized:
            isAuthorized = true
        case .notDetermined, .restricted, .denied:
            isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
        @unknown default:
            fatalError("알려지지 않은 카메라 장치 권한 획득 유형이 존재")
        }
        
        return isAuthorized
    }
    
    func setUpCaptureSession() {
        guard session.inputs.isEmpty else { return }
        session.beginConfiguration()
        setUpVideoOutput()
        
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
        let dimension = ResolutionType.HD.dimension
        let settings = AVCapturePhotoSettings()
        settings.maxPhotoDimensions = CMVideoDimensions(width: dimension.width, height: dimension.height)
        settings.flashMode = .auto
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
        guard let videoInput = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(videoInput)
        else { return }
        session.addInput(videoInput)
    }
    
    private func addCaptureDeviceOutput() {
        guard session.canAddOutput(photoOutput),
              session.canAddOutput(videoOutput)
        else { return }
        session.sessionPreset = .photo
        session.addOutput(photoOutput)
        session.addOutput(videoOutput)
        session.commitConfiguration()
    }
    
    private func setUpVideoOutput() {
        videoOutput.setSampleBufferDelegate(self, queue: sampleBufferQueue)
    }
}

extension DefaultPhotoCaptureProcessor: AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        delegate?.captureOutput(self, didOutput: pixelBuffer)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let error = error else {
            return print("사진 촬영됨")
        }
        print(error)
    }
}
