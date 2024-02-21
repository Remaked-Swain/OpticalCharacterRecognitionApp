#  OpticalCharacterRecognitionApp
모바일 문서, 신분증, 명함 인식 어플리케이션

[미니인턴 기업 과제 안내페이지](https://miniintern.com/projects/1269), 미네르바소프트 채용형 기업 과제 수행

## Overview
이 저장소는 미니인턴 주관, 미네르바소프트 제공의 채용형 기업 과제인 **Magic_IDR**앱 프로젝트를 담고 있습니다.

## 스크린샷
|**명함 인식**|**도서 인식**|
|:--:|:--:|
|<img src="https://github.com/Remaked-Swain/ScreenShotRepository/blob/main/Magic_IDR/Scanner.PNG?raw=true" alt="Scanner" width="300px">|<img src="https://github.com/Remaked-Swain/ScreenShotRepository/blob/main/Magic_IDR/Scanner2.PNG?raw=true" alt="Scanner2" width="300px">|

|**갤러리 화면**|**편집 화면**|
|:--:|:--:|
|<img src="https://github.com/Remaked-Swain/ScreenShotRepository/blob/main/Magic_IDR/Gallery.PNG?raw=true" alt="Gallery" width="300px">|<img src="https://github.com/Remaked-Swain/ScreenShotRepository/blob/main/Magic_IDR/Editer.PNG?raw=true" alt="Edtier" width="300px">|

## Discussions
앱의 주요 기능에 대해 설명합니다.

**Scanner 화면**
* 카메라로 들어오는 이미지 버퍼에 대하여 사각형을 감지하고, 감지한 사각형의 변과 모서리를 강조하는 선을 그립니다.
* 물체가 감지된 후 약 1.5초가 경과하면 자동으로 캡쳐를 진행합니다. (미구현)
* 물체가 감지됐을 때 촬영했을 경우, 감지된 물체를 따라 PerspectiveCorrection 필터를 적용한 뒤 Crop된 사진을 저장합니다.
* 물체가 감지되지 않았을 때 촬영했을 경우, Editer 화면으로 이동해 편집을 수행합니다.

** Gallery 화면**
* 저장된 사진을 페이지 갤러리 형태로 확인할 수 있습니다.
* 갤러리에서 사진을 삭제할 수 있습니다.
* 갤러리에서 사진을 다시 편집하도록 Editer 화면으로 이동할 수 있습니다.

** Editer 화면**
* 이미지 내 사각형 물체에 대해 자동으로 사각형을 강조하는 선을 그립니다. 이를 마그네틱 기능이라고 표현합니다.
* 사용자는 강조 영역을 직접 조정해 이미지를 편집할 수 있습니다.
* 마그네틱 기능, 혹은 사용자가 직접 조정한 강조 영역에 대해 PerspectiveCorrection 필터를 적용한 뒤 Crop된 사진을 저장합니다. (미구현)

**기타 사항**
1. 현재 Scanner 화면에서는 '명함'을 대상으로 감지를 수행하도록 명함의 종횡비인 1.75 값을 감지 옵션으로 설정했습니다.
2. Editer 화면에서는 사각형 물체를 감지하는데 실패한 이미지를 대상으로 재조정 해야하므로 감지 옵션을 기본값으로 재설정했습니다.

---

## 구현
앱을 구현하기 위하여 만든 객체들을 소개합니다.

### PhotoCaptureProcessor
카메라 장치의 연결과 비디오, 사진 캡쳐 작업을 수행하는 객체입니다.

**PhotoCaptureProcessor 역할 부여**
```swift
protocol PhotoCaptureProcessor: AVCaptureVideoDataOutputSampleBufferDelegate & AVCapturePhotoCaptureDelegate {
    var session: AVCaptureSession { get }
    var delegate: CaptureProcessorDelegate? { get set }
    func setUpCaptureProcessor() throws
    func capture()
    func start()
    func stop()
}
```
> `PhotoCaptureProcessor`는 카메라 장치 사용을 위한 권한 확인 및 획득을 수행할 수 있으며,
> 
> 카메라 장치로 들어와 해석된 이미지 버퍼를 실시간으로 화면에 보여주도록 연결하고 사진 캡쳐를 수행할 수 있습니다.

---

**AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate**
```swift
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
```
> `PhotoCaptureProcessor`는 AVFoundation 프레임워크의 위와 같은 델리게이션 프로토콜을 채택하여 이미지 버퍼와 캡쳐된 사진에 대한 처리를 대신 수행합니다.
>
> 또한 `frameCount`와 `frameCountLimit` 변수로 불필요하게 과다한 이미지 처리를 회피해 CPU 부하를 줄이도록 하고 있습니다.

---

### DocumentDetector
이미지 내 명함, 신분증, 문서 등의 사각형 물체를 감지하는 객체입니다.

**DocumentDetector 역할 부여**
```swift
protocol DocumentDetector: FilterProtocol {
    func detect(in ciImage: CIImage, forType detectionType: DetectorType) throws -> RectangleModel
}
```
> `DocumentDetector`는 `PhotoCaptureProcessor`에서 처리한 이미지 버퍼 및 CIImage 타입에 대하여 사각형 감지를 수행합니다.
>
> 또한 명함, 신분증, A4용지 등, 찾아낼 사각형 물체의 특징에 대해 설정할 수 있도록 `DetectorType`을 선언했습니다.

---

### DocumentPersistentContainer
촬영된 이미지 및 감지된 사각형 물체 정보를 저장하고 유지할 수 있도록 해주는 객체입니다.

현재 In-Memory Persistence 기능만 구현되어 있습니다.

**DocumentPersistentContainer 역할 부여**
```swift
protocol HoldingsCountable {
    var count: Int { get }
    var isEmpty: Bool { get }
}

protocol DocumentStorable {
    func store(document: Document)
}

protocol DocumentFetchable {
    func fetch(for index: Int) throws -> Document
    func fetch() throws -> [Document]
}

protocol DocumentDeletable {
    func delete(at index: Int) throws
}

typealias DocumentPersistentContainerProtocol = HoldingsCountable & DocumentStorable & DocumentFetchable & DocumentDeletable
```
> `DocumentPersistentContainer`는 위처럼 일반적인 Collection 타입이 제공하는 기능들을 지원합니다.
