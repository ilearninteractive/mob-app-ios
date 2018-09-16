//
//  ViewController.swift
//  ssotest
//
//

import UIKit
import WebKit

class SSOLoginViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler  {
    
    var webView: WKWebView!
    let userContentController = WKUserContentController()
    //    var accessTokenCode: String
    
    override func loadView() {
        super.loadView()
        
        let config = WKWebViewConfiguration()
        config.userContentController = userContentController
        
        self.webView = WKWebView(frame: self.view.bounds, configuration: config)
        self.webView.navigationDelegate = self
        userContentController.add(self, name: "sendTokenToApplication")
        
        self.view = self.webView
        
        //        webView = WKWebView()
        //        webView.navigationDelegate = self
        //        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: "https://edxmoe.ilearnme.com/oauth2/authorize/?scope=openid+profile+email+permissions&state=xyz&redirect_uri=https://edxmoe.ilearnme.com/api/mobile/v0.5/?app=ios&response_type=code&client_id=0d7d01a1f2a866866285")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else { return completionHandler(.useCredential, nil) }
        let exceptions = SecTrustCopyExceptions(serverTrust)
        SecTrustSetExceptions(serverTrust, exceptions)
        completionHandler(.useCredential, URLCredential(trust: serverTrust))
        
    }
    
    func getAsyncRequest(oauthCode: String, completion:  @escaping (String) -> ()) {
        let url = URL(string: "https://edxmoe.ilearnme.com/oauth2/access_token")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "client_id=0d7d01a1f2a866866285&client_secret=be3a30b12ca7f198431ae670c7160beef0c2466f&grant_type=authorization_code&code=\(oauthCode)"
        request.httpBody = postString.data(using: .utf8)
        
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error ?? "" as! Error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
//                print("statusCode should be 200, but is \(httpStatus.statusCode)")
//                print("response = \(response)")
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            //            print("responseString = \(responseString)")
            let accessToken = "\(responseString ?? "")"
            completion(accessToken)
        }
        task.resume()
        
    }
    
    
    func getAccessToken(oauthCode: String){
        getAsyncRequest(oauthCode: oauthCode) { accessToken in
            print(accessToken)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
//        print("Page Being loaded is \(navigationAction.request)")
        
        // TODO:
        
        let urlRequestResult = "\(navigationAction.request)"
        if urlRequestResult.range(of: "code=") != nil {
            let oauthCode = "\(navigationAction.request)".components(separatedBy: "code=")[1]
//            print("oauthCode = \(oauthCode)" )
            //            let accessToken = getAccessToken(oauthCode: oauthCode)
            getAsyncRequest(oauthCode: oauthCode) { accessToken in
//                print("WEBVIEW PRINT \(accessToken)")
                //                self.accessTokenCode = accessToken
            }
        }
        
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        let headers = (navigationResponse.response as! HTTPURLResponse).allHeaderFields
//        print(headers)
        
        decisionHandler(.allow)
    }
    
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        
        //        let tokensArray: NSMutableArray = message.body as! NSMutableArray
        //        let tokenDict = (objects as! [message.body]).first
        //
        //        if let json = message.body as? [[String:AnyObject?]] {
        //            for data in message.body { // Enumerate the array of dicts to get value.
        //                print(data.objectForKey("access_token"))
        //            }
        //        }
        //
        //        if let jsonDataArray = try? JSONSerialization.jsonObject(with: tokensArray!, options: []) as? [[String: Any]] {
        //            for eachData in jsonDataArray {
        //                let eachStop = busStops(jsonDataDictiony: jsonDataDictionary)
        //            }
        //        }
        //
        //
        //        let tokenDict = tokensArray.first as? NSDictionary
        
        
        let messageBody = message.body as? NSArray
        
//        print(messageBody!)

        
        if (messageBody?.count == 0 ||  messageBody == nil)  {
            return
        }
        //
        let tokenDict = messageBody?.firstObject as! NSDictionary
        let access_token = tokenDict["access_token"] as! String
        let token_type = tokenDict["token_type"] as! String
        let expires_in = tokenDict["expires_in"] as! String
        let scope = tokenDict["scope"] as! String
//        print(access_token, token_type, expires_in, scope)
        //        }
    }
    
}

