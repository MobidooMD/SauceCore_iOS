import Foundation
import UIKit
import WebKit

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

open class WebViewManager: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {
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
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        configureWebView()
        setupWebViewLayout()
        setupButtons()
    }
    
    public func configureWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        configuration.allowsInlineMediaPlayback = true
        configuration.userContentController = contentController
        configuration.allowsPictureInPictureMediaPlayback = true
        
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
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
    
    public func startPictureInPicture() {
        PIPKit.startPIPMode()
    }
    
    public func stopPictureInPicture() {
        // Logic to stop PIP
        PIPKit.dismiss(animated: true)
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
            startPictureInPicture()
            leftButton.isHidden = false
            rightButton.isHidden = false
        case MessageHandlerName.tokenError.rawValue:
            delegate?.webViewManager?(self, didReceiveTokenErrorMessage: message)
        case MessageHandlerName.pictureInPictureOn.rawValue:
            delegate?.webViewManager?(self, didReceivePictureInPictureOnMessage: message)
        default:
            break
        }
    }
    
    public func webViewManager(_ manager: WebViewManager, didFailWithError error: Error) {
        // Error handling logic
        print("Error occurred: \(error.localizedDescription)")
    }
}

extension WebViewManager: PIPUsable {
    public var initialState: PIPState { return .full }
}