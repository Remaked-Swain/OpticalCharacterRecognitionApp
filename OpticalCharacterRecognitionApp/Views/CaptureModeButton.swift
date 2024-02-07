import UIKit

enum CaptureMode {
    case automatic, manual
    
    var title: String {
        switch self {
        case .automatic:
            "자동"
        case .manual:
            "수동"
        }
    }
}

protocol CaptureModeButtonProtocol {
    var currentMode: CaptureMode { get }
    func toggleCaptureMode()
}

final class CaptureModeButton: UIButton, CaptureModeButtonProtocol {
    var currentMode: CaptureMode
    
    init(currentMode: CaptureMode = .automatic) {
        self.currentMode = currentMode
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func toggleCaptureMode() {
        currentMode == .automatic ? setTitle(.manual) : setTitle(.automatic)
    }
    
    private func setTitle(_ mode: CaptureMode) {
        self.setTitle(mode.title, for: self.state)
    }
}
