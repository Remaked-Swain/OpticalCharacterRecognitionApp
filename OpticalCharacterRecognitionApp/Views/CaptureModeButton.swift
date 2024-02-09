import UIKit

final class CaptureModeButton: UIButton {
    enum CaptureMode {
        case automatic
        case manual
        
        var title: String {
            switch self {
            case .automatic:
                "자동"
            case .manual:
                "수동"
            }
        }
    }
    
    private var currentMode: CaptureMode = .automatic {
        didSet {
            setTitle(currentMode)
        }
    }
    
    func configureCaptureButton() {
        setTitle(currentMode)
    }
    
    func toggleCaptureMode() {
        currentMode = currentMode == .automatic ? .manual : .automatic
    }
    
    private func setTitle(_ mode: CaptureMode) {
        self.setTitle(mode.title, for: .normal)
    }
}
