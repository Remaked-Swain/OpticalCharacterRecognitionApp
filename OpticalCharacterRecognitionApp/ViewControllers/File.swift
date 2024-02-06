import UIKit
import AVFoundation

final class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    let session = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    let output = AVCaptureVideoDataOutput()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
        session.addInput(input)

        output.videoSettings = [AVVideoWidthKey: NSNumber(integerLiteral: 390),
                                AVVideoHeightKey: NSNumber(integerLiteral: 844),
                                AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill]
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoQueue"))
        session.addOutput(output)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resize
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global().async {
            self.session.startRunning()
        }
    }
        
    
    // AVCaptureVideoDataOutputSampleBufferDelegate method
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
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
            DispatchQueue.main.async {
                self.previewLayer.sublayers?.removeSubrange(1...)
            }
            return
        }
    
        DispatchQueue.main.async {
            self.previewLayer.sublayers?.removeSubrange(1...)
            
            // 이미지의 크기와 뷰의 크기를 사용하여 비율 계산
            let scaleX = self.view.bounds.width / ciImage.extent.width
            let scaleY = self.view.bounds.height / ciImage.extent.height
            
            let topLeft = CGPoint(x: rectangle.topLeft.x * scaleX, y: rectangle.topLeft.y * scaleY)
            let topRight = CGPoint(x: rectangle.topRight.x * scaleX, y: rectangle.topRight.y * scaleY)
            let bottomLeft = CGPoint(x: rectangle.bottomLeft.x * scaleX, y: rectangle.bottomLeft.y * scaleY)
            let bottomRight = CGPoint(x: rectangle.bottomRight.x * scaleX, y: rectangle.bottomRight.y * scaleY)
            
            let minX = min(topLeft.x, bottomLeft.x)
            let minY = min(topLeft.y, topRight.y)
            let maxX = max(bottomRight.x, topRight.x)
            let maxY = max(bottomLeft.y, bottomRight.y)
            
            let newRect = CGRect(x: minX, y: minY, width: maxX-minX, height: maxY-minY)
            
            let rectLayer = CALayer()
            rectLayer.frame = newRect
            rectLayer.backgroundColor = UIColor.green.withAlphaComponent(0.3).cgColor
            rectLayer.borderColor = UIColor.black.cgColor
            rectLayer.borderWidth = 2
            
            self.previewLayer.addSublayer(rectLayer)
        }
    }
}
