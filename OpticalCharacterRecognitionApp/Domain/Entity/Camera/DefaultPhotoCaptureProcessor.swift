import Foundation
import AVFoundation

protocol PhotoCapture {
    func checkPermission() async -> Bool
    func setUpCaptureSession()
    func capture(resolution: ResolutionType, quality: AVCapturePhotoOutput.QualityPrioritization)
}

final class DefaultPhotoCaptureProcessor: PhotoCapture {
    // MARK: Properties
    private let session: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = .medium
        return session
    }()
    private let output = AVCapturePhotoOutput()
    private let previewLayer = AVCaptureVideoPreviewLayer()
    
    // MARK: Dependencies
    weak var delegate: AVCapturePhotoCaptureDelegate?
    
    // MARK: Interface
    func checkPermission() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        var isAuthorized: Bool = false
        
        switch status {
        case .authorized:
            isAuthorized = true
        case .notDetermined, .restricted, .denied:
            isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
        default:
            break
        }
        
        return isAuthorized
    }
    
    func setUpCaptureSession() {
        guard session.inputs.isEmpty else { return }
        session.beginConfiguration()
        
        do {
            let videoDevice = try selectCaptureDevice(in: .back)
            addCaptureDeviceInput(device: videoDevice)
        } catch {
            guard let error = error as? CameraError else {
                return print(error)
            }
            print(error.debugDescription)
        }
    }
    
    func capture(resolution: ResolutionType = .quadHD, quality: AVCapturePhotoOutput.QualityPrioritization = .balanced) {
        guard let delegate = delegate else { return }
        let dimension = resolution.dimension
        let settings = AVCapturePhotoSettings()
        settings.maxPhotoDimensions = CMVideoDimensions(width: dimension.width, height: dimension.height)
        settings.flashMode = .auto
        settings.photoQualityPrioritization = quality
        output.capturePhoto(with: settings, delegate: delegate)
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
        let photoOutput = AVCapturePhotoOutput()
        guard session.canAddOutput(<#T##output: AVCaptureOutput##AVCaptureOutput#>)
    }
}
