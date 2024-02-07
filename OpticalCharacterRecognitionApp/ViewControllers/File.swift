import UIKit
import AVFoundation
import Photos

final class TemporaryPhotoDetectorViewController: UIViewController {
    private let motionDetector = MotionDetector()

    // MARK: - Use Case
    // capture session
    private let session = AVCaptureSession()
    // photo output
    private let photoOutput = AVCapturePhotoOutput()
    // video output
    private let videoOutput = AVCaptureVideoDataOutput()
    // video preview
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer()
        layer.session = session
        layer.frame = view.bounds
        layer.videoGravity = .resizeAspectFill
        // MARK: - Preview layer 회전 설정
//        layer.connection?.videoOrientation = .portrait
        
        return layer
    }()
    
    // MARK: - View
    // shutter button
    private let shutterButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        button.layer.cornerRadius = 100
        button.layer.borderWidth = 10
        button.layer.borderColor = UIColor.red.cgColor
        button.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
        
        return button
    }()
    
    
    // MARK: - UseCase
    private var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            
            var isAuthorized = status == .authorized
            
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            
            return isAuthorized
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.layer.addSublayer(previewLayer)
        view.addSubview(shutterButton)
        setUpCamera()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        shutterButton.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height - 200)
    }
    
    // MARK: - Use Case
    private func setUpCamera() {
        Task {
            guard await isAuthorized else { return }
        }
        
        session.beginConfiguration()
//        guard let device = AVCaptureDevice.default(for: .video) else { return }
        // MARK: - For Debugging, Changed
        
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInUltraWideCamera], mediaType: .video, position: AVCaptureDevice.Position.back)
        
        do {
            let input = try AVCaptureDeviceInput(device: discoverySession.devices.first!)
            if session.canAddInput(input) {
                session.addInput(input)
            }
        } catch {
            print(error)
        }
        
        // MARK: - Photo Output
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        
        // MARK: - Video Output
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        session.sessionPreset = .hd4K3840x2160
        //        photoOutput.maxPhotoDimensions = .init()
        session.commitConfiguration()
        
        setVideoOutput()
        

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            session.startRunning()
        }
    }
    
    // MARK: - ViewModel
    // setting도 주입받도록...
    @objc
    private func didTapTakePhoto() {
        let setting = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: setting, delegate: self)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
// MARK: - Use Case
extension TemporaryPhotoDetectorViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else {
            return
        }
        let image = UIImage(data: data)
        let imageView = UIImageView(image: image)
        
        // TODO: 다른 뷰로 전환되면 session 종료
        //        session?.stopRunning()
        
        // TODO: repoint 되는 분기
        
        // TODO: (갤러리 말고) 저장하는 로직이 여기로 와야함
        save(photo: photo)
    }
}

// MARK: - Private Methods
// MARK: - Use Case
extension TemporaryPhotoDetectorViewController {
    private func save(photo: AVCapturePhoto) {
        Task {
            // 권한 요청
            guard let phAccessLevel = PHAccessLevel(rawValue: PHAccessLevel.addOnly.rawValue) else { return }
            let status = await PHPhotoLibrary.requestAuthorization(for: phAccessLevel)
            guard status == .authorized else {
                return
            }
            
            // 사진 앨범에 저장
            try await PHPhotoLibrary.shared().performChanges {
                let creationRequest = PHAssetCreationRequest.forAsset()
                guard let data = photo.fileDataRepresentation() else { return }
                creationRequest.addResource(with: .photo, data: data, options: nil)
            }
        }
    }
}

extension TemporaryPhotoDetectorViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    // MARK: - ViewModel. Use Case에서의 비즈니스 로직을 위해 미리 가공하고 넘겨주면 좋지 않을까?
    func setVideoOutput() {
        videoOutput.videoSettings = [AVVideoWidthKey: view.bounds.width,
                                    AVVideoHeightKey: view.bounds.height,]
        //                               AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill]
        
        // MARK: - AVCaptureVideoDataOutput의 회전 설정
        
        // !!!: .videoOrientation이 deprecated 되어 .videoRotationAngle를 사용하는 것이 맞으나,
        // !!!: 과제 명세 상, 혹시 모를 iOS 하위 버전에 대한 호환성을 고려하여 수정하지 않았음.
        videoOutput.connection(with: .video)?.videoOrientation = .portrait
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoQueue"))
    }
    
    // MARK: - Use Case
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // MARK: - View. 다만, 해당 로직이 View - mode
        Task { @MainActor in
            previewLayer.sublayers?.removeSubrange(1...)
        }
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        let context = CIContext()
        let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorAspectRatio: 1.414] as [String : Any]
        
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -ciImage.extent.height)
        let transformedCIImage = ciImage.transformed(by: transform)
        
        let rectangleDetector = CIDetector(ofType: CIDetectorTypeRectangle, context: context, options: options)!
        guard let rectangles = rectangleDetector.features(in: transformedCIImage) as? [CIRectangleFeature] else { return }
        
        var maxWidth: CGFloat = 0
        var maxHeight: CGFloat = 0
        var biggestRectangle: CIRectangleFeature?
        
        for rectangle in rectangles {
            let minX = min(rectangle.topLeft.x, rectangle.bottomLeft.x)
            let minY = min(rectangle.bottomLeft.y, rectangle.bottomRight.y)
            let maxX = max(rectangle.bottomRight.x, rectangle.topRight.x)
            let maxY = max(rectangle.topLeft.y, rectangle.topRight.y)
            
            if (maxX - minX > maxWidth && maxY - minY > maxHeight) {
                maxWidth = maxX - minX
                maxHeight = maxY - minY
                biggestRectangle = rectangle
            }
        }
        
        guard let rectangle = biggestRectangle else {
            return
        }
        
        Task { @MainActor in
            if motionDetector.isShaking { return }
//            previewLayer.sublayers?.removeSubrange(1...)
            
            // MARK: - 이미지의 크기와 뷰의 크기를 사용하여 비율 계산
            let scaleX = view.bounds.width / ciImage.extent.width
            let scaleY = view.bounds.height / ciImage.extent.height
            
            // MARK: - 사각형의 좌표를 뷰의 좌표계로 변환
            let topLeft = CGPoint(x: rectangle.topLeft.x * scaleX-10, y: rectangle.topLeft.y * scaleY)
            let topRight = CGPoint(x: rectangle.topRight.x * scaleX+20, y: rectangle.topRight.y * scaleY)
            let bottomLeft = CGPoint(x: rectangle.bottomLeft.x * scaleX-10, y: rectangle.bottomLeft.y * scaleY)
            let bottomRight = CGPoint(x: rectangle.bottomRight.x * scaleX+20, y: rectangle.bottomRight.y * scaleY)
            
            // MARK: - 대각, 기울임 등의 상황에서도 사각형을 그려줌
            let path = UIBezierPath()
            path.move(to: topLeft)
            path.addLine(to: topRight)
            path.addLine(to: bottomRight)
            path.addLine(to: bottomLeft)
            path.close()
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.fillColor = UIColor.green.withAlphaComponent(0.3).cgColor
            shapeLayer.strokeColor = UIColor.black.cgColor
            shapeLayer.lineWidth = 2

            previewLayer.addSublayer(shapeLayer)
        }
    }
}
