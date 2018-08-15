//
// Created by Anton Korobko on 8/1/18.
// Copyright (c) 2018 edX. All rights reserved.
//

import Foundation
import UIKit
import WebKit
class AdditionalPagesViewController: UIViewController, UIGestureRecognizerDelegate , UIWebViewDelegate, WKNavigationDelegate  {

    let wv = WKWebView(frame: UIScreen.main.bounds)
    var urlPageToOpen:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url =  NSURL(string: urlPageToOpen) else { return }
        wv.navigationDelegate = self
        wv.load(NSURLRequest(url: url as URL) as URLRequest)
        view.addSubview(wv)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated{
            if let newURL = navigationAction.request.url,
               let host = newURL.host , !host.hasPrefix("www.google.com") &&
                       UIApplication.shared.canOpenURL(newURL) &&
                       UIApplication.shared.openURL(newURL) {
//                print(newURL)
//                print("Redirected to browser. No need to open it locally")
                decisionHandler(.cancel)
            } else {
//                print("Open it locally")
                decisionHandler(.allow)
            }
        } else {
//            print("not a user click")
            decisionHandler(.allow)
        }
    }
}
