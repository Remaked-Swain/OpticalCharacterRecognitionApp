import CoreMotion

protocol MotionDetectable {
    var isShaking: Bool { get }
    func startDetection()
    func stopDetection()
}

final class MotionDetector: MotionDetectable {
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    private let motionThreshold: Double = 0.1
    
    var isShaking: Bool = false
    
    deinit {
        stopDetection()
    }
    
    func startDetection() {
        motionManager.startDeviceMotionUpdates(to: queue) { [weak self] (motion, _) in
            guard let self = self,
                  let motion = motion
            else { return }
            
            let userAcceleration: CMAcceleration = motion.userAcceleration
            let magnitude = sqrt(userAcceleration.x * userAcceleration.x +
                                 userAcceleration.y * userAcceleration.y +
                                 userAcceleration.z * userAcceleration.z)
            
            if magnitude >= motionThreshold {
                isShaking = true
            } else {
                isShaking = false
            }
        }
    }
    
    func stopDetection() {
        motionManager.stopDeviceMotionUpdates()
    }
}
