//
//  UrlsViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 11/07/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit
import WebKit

class UrlsViewController: AbstractUIViewController, WKNavigationDelegate  {
    
    @IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var pageTitle: UILabel!
    
    @IBOutlet weak var webContent: WKWebView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var titlePage:String = "NO TITLE"
    var webUrlPage:String?
    var contentMode:UIView.ContentMode = .center
    var webDomain:String? = "www.zorroabarrotero.com.mx"
    var removeChatComponent:Bool = true
    
    var keepWebViewActiveTimer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webContent.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        webContent.configuration.preferences.javaScriptEnabled = true
        webContent.contentMode = contentMode
                   
        pageTitle.text = titlePage
        pageTitle.numberOfLines = 1
        pageTitle.adjustsFontSizeToFitWidth = true
        pageTitle.minimumScaleFactor = 0.3
        
        //webUrlPage = "http://whatsmyuseragent.org"
        if let webUrlPage = self.webUrlPage {
            let sscapedwebUrlPage = webUrlPage.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            if let scapedwebUrlPage = sscapedwebUrlPage {
                debugPrint("webUrlPage: [\(scapedwebUrlPage)]")
                let url = URL(string: scapedwebUrlPage)
                debugPrint("url: [\(String(describing: url))]")
                if let ourl = url {
                    let nsurl = NSURLRequest(url: ourl)
                    debugPrint("nsurl: [\(nsurl)]")
                    webContent.load(nsurl as URLRequest)
                }
            }
        }
        webContent.navigationDelegate = self
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(back))
        backButton.addGestureRecognizer(tap1)
        backButton.isUserInteractionEnabled = true
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(openInBrowser))
        pageTitle.addGestureRecognizer(tap2)
        pageTitle.isUserInteractionEnabled = true
        
        indicator.hidesWhenStopped = true
        indicator.isHidden = true
        
        /*
        keepWebViewActiveTimer = Timer(timeInterval: 0.2,
                                           target: self,
                                           selector: #selector(self.keepWKWebViewActive),
                                           userInfo: nil,
                                           repeats: true)
        */
    }
    
    @objc func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func openInBrowser() {
        let title = "Zorro"
        let message = "¿Desea abrir esta liga en navegador Web?"
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            
            if let webUrlPage = self.webUrlPage {
                let sscapedwebUrlPage = webUrlPage.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                if let scapedwebUrlPage = sscapedwebUrlPage {
                    let url = URL(string: scapedwebUrlPage)
                    if let ourl = url {
                        if(UIApplication.shared.canOpenURL(ourl)) {
                            UIApplication.shared.open(ourl) { (result) in
                                debugPrint("Success")
                            }
                        }
                        
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    /*
    // MARK: WKWebView Delegate methods
    */
    
    // Equivalent of shouldStartLoadWithRequest
    @available(iOS 13.0, *)
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        debugPrint("Webview decidePolicyFor: \(navigationAction.navigationType)")
        debugPrint("Webview URL: \(String(describing: navigationAction.request.url))")
        
        if let webDomain = self.webDomain {
            let handlerInvoker : (WKNavigationActionPolicy) -> Void = { action in
                decisionHandler(action, preferences)
            }
            handlerPolicyNavigationDomainCase(webDomain: webDomain, webView: webView, navigationAction: navigationAction, handlerInvoker: handlerInvoker)
            
            return
        }
        
        // Normal flow
        debugPrint("NORMAL Navigation FLOW")
        if (navigationAction.navigationType == .linkActivated){
            decisionHandler(.cancel, preferences)
        } else {
            decisionHandler(.allow, preferences)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        debugPrint("Webview decidePolicyFor: \(navigationAction.navigationType)")
        debugPrint("Webview URL: \(String(describing: navigationAction.request.url))")
        
        if let webDomain = self.webDomain {
            let handlerInvoker : (WKNavigationActionPolicy) -> Void = { action in
                decisionHandler(action)
            }
            handlerPolicyNavigationDomainCase(webDomain: webDomain, webView: webView, navigationAction: navigationAction, handlerInvoker: handlerInvoker)
            
            return
        }
        
        // Normal flow
        debugPrint("NORMAL Navigation FLOW")
        if (navigationAction.navigationType == .linkActivated){
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func handlerPolicyNavigationDomainCase(webDomain: String, webView: WKWebView, navigationAction: WKNavigationAction, handlerInvoker: (WKNavigationActionPolicy) -> Void) {
    
        // This case was only for the specific case of ZorroAbarrotero links to be opened within the app.
        // TO-DO: Search for a way to avoid duplicated code
        if let host = navigationAction.request.url?.host {
            if host.contains(webDomain) {
                debugPrint("Allowing request")
                handlerInvoker(.allow)
                return
            }
            
            if let url = navigationAction.request.url?.absoluteString {
                if url.contains("www.instagram.com/zorroabarroterooficial/") ||
                    url.contains("www.facebook.com/ZorroAbarrotero/") ||
                    host.contains("api.whatsapp.com") ||
                    host.contains("widget-v1.smartsuppcdn.com") ||
                    url.contains("www.youtube.com/channel/UCJ-JJZrCb_YyT8jUR8M3SIw") ||
                    host.contains("goo.gl") {
                    debugPrint("Allowing Specific host request")
                    
                    let title = "Advertencia"
                    let message = "Esta apunto de salir de Zorro App, ¿Esta seguro de continuar?"
                    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                        let appURL = navigationAction.request.url!
                        if(UIApplication.shared.canOpenURL(appURL)) {
                            UIApplication.shared.open(appURL) { (result) in
                                debugPrint("Success")
                            }
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    handlerInvoker(.cancel)
                    return
                }
            }
            
            if host.contains("www.youtube.com")
               || host.contains("tpc.googlesyndication.com") {
                debugPrint("Allowing request")
                handlerInvoker(.allow)
                return
            }
        }
        
        if navigationAction.request.url?.scheme == "tel" || navigationAction.request.url?.scheme == "mailto" {
            debugPrint("Open special Schema")
            let appURL = navigationAction.request.url!
            if(UIApplication.shared.canOpenURL(appURL)) {
                UIApplication.shared.open(appURL) { (result) in
                    debugPrint("Success")
                }
            }
            handlerInvoker(.cancel)
            return
        }
        
        debugPrint("Cancelling request")
        handlerInvoker(.cancel)
        return
    }
    
    // Equivalent of webViewDidStartLoad
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Webview started Loading")
        indicator.isHidden = false
        indicator.startAnimating()
    }
    
    // Equivalent of didFailLoadWithError
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Webview fail with error \(String(describing: error))");
        indicator.stopAnimating()
        if(removeChatComponent) {
            removeScriptTags()
        }
    }
    
    // Equivalent of webViewDidFinishLoad
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Webview did finish load")
        indicator.stopAnimating()
        if(removeChatComponent) {
            removeScriptTags()
        }
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil || navigationAction.targetFrame?.isMainFrame == false {
            if let urlToLoad = navigationAction.request.urlRequest {
                webView.load(urlToLoad)
                //handleWebViewLink?(urlToLoad.absoluteString)
                // this is a closure, which is handled in another class. Nayway... here you get the url of "broken" links
            }
        }
        return nil
    }
    
    /*
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("didReceive challenge:")
    }
     */
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("didCommit navigation:")
    }
    
    /*
     * Ensure to remove the Chat Component by trying at the first 1.5 secons after load complete 3 times.
     */
    private func removeScriptTags() {
        DispatchQueue.background(delay: 0.5, completion:{
            self.removeChatComponentInDom()
        })
        
        DispatchQueue.background(delay: 1.0, completion:{
            self.removeChatComponentInDom()
        })
        
        DispatchQueue.background(delay: 1.5, completion:{
            self.removeChatComponentInDom()
        })
    }
    
    private func removeChatComponentInDom() {
        /*
        self.webContent.evaluateJavaScript("var list=document.getElementsByTagName('script');var item=list[list.length -1];item.parentNode.removeChild(item);list=document.getElementsByTagName('script');console.log(list);for (var i = 0, len = list.length; i < len; i++) { var item = list[i]; if(item.getAttribute('src') == 'https://www.smartsuppchat.com/loader.js?') { console.log(item); item.parentNode.removeChild(item); break; } } var chats=document.getElementById('chat-application'); if(chats) { chats.parentNode.removeChild(chats); }",
        completionHandler: nil)
        */
        
        if let webContent = self.webContent {
            webContent.evaluateJavaScript("var chats=document.getElementById('chat-application'); if(chats) { chats.parentNode.removeChild(chats); }",
                completionHandler: { (result, error) in
                    debugPrint("removeChatComponentInDom executed succesfully:   \(String(describing: result)) - \(String(describing: error)) ")
                })
        }
    }
    
    @objc private func keepWKWebViewActive() {
        if let webContent = self.webContent {
            webContent.evaluateJavaScript("1+1", completionHandler: nil)
        }
    }
    

}
