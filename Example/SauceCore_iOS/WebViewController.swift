//
//  WebViewController.swift
//  SauceCore_iOS_Example
//
//  Created by DevPlayNew on 2/13/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import UIKit
import WebKit
import SauceCore_iOS

class WebViewController: WebViewManager {
    var url: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.pipSize = CGSize(width: 100, height: 150)
       
       
        // 초기 웹 페이지 로드
        if let url = url {
            self.loadURL(url)
        }
        
    }
    
//    // 필요에 따라 WebViewManager에서 정의한 메서드를 오버라이드하여 커스터마이즈할 수 있습니다.
//    // 예: 사용자 정의 버튼 이벤트 핸들러
    override func leftButtonTapped() {
         super.leftButtonTapped() // 기본 구현을 호출하거나, 사용자 정의 동작을 구현할 수 있습니다.
        print("Left button custom action in SomeViewController")
    }
    
    override func rightButtonTapped() {
         super.rightButtonTapped() // 기본 구현을 호출하거나, 사용자 정의 동작을 구현할 수 있습니다.
        
        print("Right button custom action in SomeViewController")
    }
}

// WebViewManagerDelegate 프로토콜 채택 및 구현
extension WebViewController: WebViewManagerDelegate {
    func webViewManager(_ manager: WebViewManager, didReceiveCustomCouponMessage message: WKScriptMessage) {
        // 커스텀 쿠폰 메시지 받았을 때의 처리 로직
        print("Received custom coupon message: \(message.body)")
    }
    
    func webViewManager(_ manager: WebViewManager, didReceiveMoveExitMessage message: WKScriptMessage) {
        print("Received custom Exit message: \(message.body)")
    }
    
    func webViewManager(_ manager: WebViewManager, didReceiveEnterMessage message: WKScriptMessage) {
        print("Received issue Enter message: \(message.body)")
    }
    
    func webViewManager(_ manager: WebViewManager, didReceivePictureInPictureMessage message: WKScriptMessage) {
        print("Received issue PIP message: \(message.body)")
    }
}
