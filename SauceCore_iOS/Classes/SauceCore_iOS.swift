import Foundation
import UIKit
import WebKit
import AVKit

public enum MessageHandlerName: String {
    case customCoupon = "sauceflexSetCustomCoupon"
    case issueCoupon = "sauceflexIssueCoupon"
    case enter = "sauceflexEnter"
    case moveExit = "sauceflexMoveExit"
    case moveLogin = "sauceflexMoveLogin"
    case moveProduct = "sauceflexMoveProduct"
    case moveBanner = "sauceflexMoveBanner"
    case onShare = "sauceflexOnShare"
    case pictureInPicture = "sauceflexPictureInPicture"
    case tokenError = "sauceflexTokenError"
    case pictureInPictureOn = "sauceflexPictureInPictureOn"
    case videoURL = "videoURL"
}

@objc public protocol WebViewManagerDelegate: AnyObject {
    @objc optional func webViewManager(_ manager: WebViewManager, didReceiveCustomCouponMessage message: WKScriptMessage)
    @objc optional func webViewManager(_ manager: WebViewManager, didReceiveIssueCouponMessage message: WKScriptMessage)
    @objc optional func webViewManager(_ manager: WebViewManager, didReceiveEnterMessage message: WKScriptMessage)
    @objc optional func webViewManager(_ manager: WebViewManager, didReceiveMoveExitMessage message: WKScriptMessage)
    @objc optional func webViewManager(_ manager: WebViewManager, didReceiveMoveLoginMessage message: WKScriptMessage)
    @objc optional func webViewManager(_ manager: WebViewManager, didReceiveMoveProductMessage message: WKScriptMessage)
    @objc optional func webViewManager(_ manager: WebViewManager, didReceiveMoveBannerMessage message: WKScriptMessage)
    @objc optional func webViewManager(_ manager: WebViewManager, didReceiveOnShareMessage message: WKScriptMessage)
    @objc optional func webViewManager(_ manager: WebViewManager, didReceivePictureInPictureMessage message: WKScriptMessage)
    @objc optional func webViewManager(_ manager: WebViewManager, didReceiveTokenErrorMessage message: WKScriptMessage)
    @objc optional func webViewManager(_ manager: WebViewManager, didReceivePictureInPictureOnMessage message: WKScriptMessage)
    @objc optional func webViewManagerDidStartPictureInPicture(_ manager: WebViewManager)
    @objc optional func webViewManagerDidStopPictureInPicture(_ manager: WebViewManager)
}

open class WebViewManager: UIViewController, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate {
    public var webView: WKWebView!
    var contentController = WKUserContentController()
    private var leftButton: UIButton!
    private var rightButton: UIButton!
    public weak var delegate: WebViewManagerDelegate?
    public var messageHandlerNames: [MessageHandlerName] = [] {
        didSet {
            registerMessageHandlers()
        }
    }
    
    public var pipSize: CGSize = CGSize(width: 100, height: 200)
    public var pipMode: Bool = false
    
    private let playerLayer = AVPlayerLayer()
    private var player = AVPlayer()
    private var pipController: AVPictureInPictureController?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        configureWebView()
        setupWebViewLayout()
        setupButtons()
    }
    
    public func configureWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.allowsInlineMediaPlayback = true
        configuration.userContentController = contentController
        configuration.allowsPictureInPictureMediaPlayback = true
        if #available(iOS 14.0, *) {
            configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            configuration.preferences.javaScriptEnabled = true
        }
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view.addSubview(webView)
    }
    
    public func loadURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    private func registerMessageHandlers() {
        for name in messageHandlerNames {
            contentController.add(self, name: name.rawValue)
        }
    }
    
    private func setupWebViewLayout() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupButtons() {
        leftButton = UIButton(type: .custom)
        rightButton = UIButton(type: .custom)
        guard let bundleURL = Bundle(for: WebViewManager.self).url(forResource: "assets", withExtension: "bundle"),
              let bundle = Bundle(url: bundleURL) else {
            return
        }
        let closeImage = UIImage(named: "CloseButton", in: bundle, compatibleWith: nil)
        let pipImage = UIImage(named: "PIPButton", in: bundle, compatibleWith: nil)
        
        
        
        // Set button images (images must be added to the project)
        leftButton.setImage(closeImage, for: .normal)
        rightButton.setImage(pipImage, for: .normal)
        
        leftButton.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
        
        leftButton.isHidden = true
        rightButton.isHidden = true
        
        view.addSubview(leftButton)
        view.addSubview(rightButton)
        
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leftButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            leftButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            rightButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            rightButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
    }
    
    
    // Left button event handler
    @objc open func leftButtonTapped() {
        PIPKit.dismiss(animated: true)
    }
    
    // Right button event handler
    @objc open func rightButtonTapped() {
        let name = "window.dispatchEvent(sauceFlexPIP(false));"
        webView.evaluateJavaScript(name) { (Result, Error) in
            if let error = Error {
                print("evaluateJavaScript Error : \(error)")
            } else {
                self.leftButton.isHidden = true
                self.rightButton.isHidden = true
                PIPKit.stopPIPMode()
            }
        }
    }
    
    private func videoPIP() {
        let script = "if (document.querySelector('video')) { document.querySelector('video').webkitSetPresentationMode('picture-in-picture'); }"
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    private func disableVideoPIP() {
        let script = """
        if (document.querySelector('video') && document.pictureInPictureElement) {
            document.exitPictureInPicture();
        }
        """
        webView.evaluateJavaScript(script) { _, error in
            if let error = error {
                print("PiP 모드 비활성화 중 오류 발생: \(error)")
            }
        }
    }
    
    
    public func startPictureInPicture() {
        if pipMode {
            PIPKit.startPIPMode()
        } else {
            videoPIP()
            webView.isHidden = true
            webView.isUserInteractionEnabled = false
        }
    }
    public func stopPictureInPicture() {
        if pipMode {
            PIPKit.dismiss(animated: true)
        } else {
            disableVideoPIP()
            webView.isHidden = true
            webView.isUserInteractionEnabled = false
        }
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case MessageHandlerName.customCoupon.rawValue:
            delegate?.webViewManager?(self, didReceiveCustomCouponMessage: message)
        case MessageHandlerName.issueCoupon.rawValue:
            delegate?.webViewManager?(self, didReceiveIssueCouponMessage: message)
        case MessageHandlerName.enter.rawValue:
            
            delegate?.webViewManager?(self, didReceiveEnterMessage: message)
        case MessageHandlerName.moveExit.rawValue:
            delegate?.webViewManager?(self, didReceiveMoveExitMessage: message)
            stopPictureInPicture()
        case MessageHandlerName.moveLogin.rawValue:
            delegate?.webViewManager?(self, didReceiveMoveLoginMessage: message)
        case MessageHandlerName.moveProduct.rawValue:
            delegate?.webViewManager?(self, didReceiveMoveProductMessage: message)
        case MessageHandlerName.moveBanner.rawValue:
            delegate?.webViewManager?(self, didReceiveMoveBannerMessage: message)
        case MessageHandlerName.onShare.rawValue:
            delegate?.webViewManager?(self, didReceiveOnShareMessage: message)
        case MessageHandlerName.pictureInPicture.rawValue:
            delegate?.webViewManager?(self, didReceivePictureInPictureMessage: message)
            //            startPictureInPicture()
            //            leftButton.isHidden = false
            //            rightButton.isHidden = false
            fetchVideoURL()
        case MessageHandlerName.tokenError.rawValue:
            delegate?.webViewManager?(self, didReceiveTokenErrorMessage: message)
        case MessageHandlerName.pictureInPictureOn.rawValue:
            delegate?.webViewManager?(self, didReceivePictureInPictureOnMessage: message)
        default:
            break
        }
        
        if message.name == "videoURL", let videoURLString = message.body as? String, let videoURL = URL(string: videoURLString) {
            // AVPlayer를 사용하여 비디오 URL로 PIP 시작
            print(message.name)
            startPictureInPictureWithAVPlayer(videoURL: videoURL)
        }
    }
    
    public func webViewManager(_ manager: WebViewManager, didFailWithError error: Error) {
        // Error handling logic
        print("Error occurred: \(error.localizedDescription)")
    }
    
    private func startPictureInPictureWithAVPlayer(videoURL: URL) {
        let playerItem = AVPlayerItem(url: videoURL)
        player = AVPlayer(playerItem: playerItem)
        if AVPictureInPictureController.isPictureInPictureSupported() {
            print("keaton111")
            pipController = AVPictureInPictureController(playerLayer: AVPlayerLayer(player: player))
            pipController?.delegate = self
            pipController?.startPictureInPicture()
        }
    }
    
    // 비디오 URL을 찾는 JavaScript 코드 실행
    func fetchVideoURL() {
        // 여기서 "yourVideoContainer video" 대신 실제 비디오 요소 선택자를 사용하세요.
        // 예를 들어, document.querySelector('video').src
        let script = """
            var videoSrc = document.querySelector('video') ? document.querySelector('video').src : '';
            webkit.messageHandlers.videoURL.postMessage(videoSrc);
            """
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
}

extension WebViewManager: PIPUsable {
    public var initialState: PIPState { return .full }
}

extension WebViewManager: AVPictureInPictureControllerDelegate {
    // Implement delegate methods as needed, for example:
    public func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP started")
    }
    
    public func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP stopped")
    }
}
