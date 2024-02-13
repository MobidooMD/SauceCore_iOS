# SauceCore_iOS

SauceCore_iOS는 애플리케이션 내에서 웹 콘텐츠의 통합 및 관리를 간소화하도록 설계된 강력한 라이브러리입니다. 웹 콘텐츠 관리, 스크립트 메시지 처리 및 사용자의 멀티태스킹 기능을 향상시키는 Picture-in-Picture (PIP) 기능을 쉽게 사용할 수 있습니다.

## 특징

- **웹 뷰 관리:** 앱 내에서 웹 콘텐츠를 쉽게 로드하고 표시합니다.
- **스크립트 메시지 처리:** 웹 콘텐츠에서 사용자 정의 스크립트 메시지를 등록하고 처리하여 인터랙티브한 웹앱 사용을 가능하게 합니다.
- **Picture-in-Picture (PIP) 모드:** 사용자가 모바일 활동을 중단하지 않고도 비디오 또는 콘텐츠를 보면서 계속 작업할 수 있도록 합니다. PIP 창 크기, 그림자 및 모서리 속성을 맞춤 설정이 가능합니다.

## 시작하기

### 설치

SauceCore_iOS를 프로젝트에 사용하는데 CocoaPods와 Swift Package Manager(SPM) 두 가지 방법을 지원합니다.

#### CocoaPods를 사용한 설치

`Podfile`에 다음을 추가하여 CocoaPods를 통해 SauceCore_iOS 설치합니다:

```swift
pod 'SauceCore_iOS'
```

그런 다음, 터미널에서 `pod install`을 실행하여 라이브러리를 프로젝트에 추가합니다.

#### Swift Package Manager를 사용한 설치

Xcode에서 프로젝트를 열고 `File` > `Swift Packages` > `Add Package Dependency...`를 선택합니다. 나타나는 대화 상자에 SauceCore_iOS Git 저장소 URL을 입력합니다.

저장소 URL: `https://github.com/MobidooMD/SauceCore.git`

필요한 버전 설정을 완료하고 패키지를 프로젝트에 추가합니다.

### 사용법

#### SauceCore_iOS 초기화 및 구성

```swift
import SauceCore_iOS

class WebViewController: WebViewManager { ..

 //스크립트 메시지를 처리하기 위한 대리자 설정
self.delegate = self

 //스크립트 메시지 핸들러 등록
self.messageHandlerNames = [.customCoupon, .issueCoupon, ...] // 핸들러 추가

 //URL 로드
loadURL("https://www.example.com")
```

#### WebViewManagerDelegate 구현

스크립트 메시지에 응답하기 위해 `WebViewManagerDelegate` 메소드를 구현합니다:

```swift
extension YourViewController: WebViewManagerDelegate {
    func webViewManager(_ manager: WebViewManager, didReceiveCustomCouponMessage message: WKScriptMessage) {
        // 사용자 정의 쿠폰 스크립트 메시지 처리
    }
    
    // 다른 대리자 메소드 구현...
}
```

#### Picture-in-Picture 모드

사용자가 비디오를 보거나 콘텐츠를 부동 창에서 볼 수 있도록 PIP 기능을 사용합니다:

```swift
// PIP 모드 시작
webViewManager.startPictureInPicture()

// PIP 모드 중지
webViewManager.stopPictureInPicture()
```

## 맞춤 설정

PIP 창의 모양을 앱의 디자인 요구 사항에 맞게 크기, 그림자 및 모서리 반경을 조정하여 맞춤 설정할 수 있습니다.
```swift
 self.pipSize = CGSize(width: 100, height: 150)
```

## 요구 사항

- iOS 11.0 이상
- Swift 5.0 이상

## 라이선스

SauceFlexWebViewManager는 MIT 라이선스에 따라 사용할 수 있습니다. 자세한 내용은 LICENSE 파일을 참조하세요.
