//
//  CustomPopUpViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 29/03/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit
import RadioGroup
import WebKit

protocol PopUpDelegate {
    func onPossitiveAction(observerId : Notification.Name?, controller : UIViewController?, popup: CustomPopUpViewController)
    
    func onNegativeAction(observerId : Notification.Name?, controller : UIViewController?, popup: CustomPopUpViewController)
    
    func onCloseAction(observerId : Notification.Name?, controller : UIViewController?, popup: CustomPopUpViewController)
}

public extension NSLayoutConstraint {
    func changeMultiplier(multiplier: CGFloat) -> NSLayoutConstraint {
        print("On changeMultiplier")
        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        newConstraint.priority = priority

        NSLayoutConstraint.deactivate([self])
        NSLayoutConstraint.activate([newConstraint])

        return newConstraint
    }
}

class CustomPopUpViewController: AbstractUIViewController, UIPickerViewDelegate, UIPickerViewDataSource, WKNavigationDelegate {

    @IBOutlet weak var popupTitle: UILabel!
    @IBOutlet weak var container: UIScrollView! //UIStackView!
    
    @IBOutlet weak var buttonContainer: UIStackView!
    @IBOutlet weak var positiveButton: UIButton!
    @IBOutlet weak var negativeButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var popUpView: RounderCornerView!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var customTitle : String = ""
    var customTitleColor : UIColor = .black
    var containerName : String = ""
    var positiveButtonLabel : String?
    var negativeButtonLabel : String?
    
    var minDate:Date?
    var cDate:Date?
    var maxDate:Date?
    
    var datePicker: UIDatePicker?
    var isDatePicker:Bool = false
    
    var isWebUrl:Bool = false
    var webUrlPage:String?
    
    var webView:WKWebView?
    var wkWebConfig:WKWebViewConfiguration?
    var contentMode:UIView.ContentMode = .center
    var webDomain:String?
    
    var myPopupButton: UIPickerView?
    var popupArray:[String] = []
    var selectedIndex:Int = 0
    var observerId : Notification.Name?
    private var chooser:Bool = false
    private var radioGroup : RadioGroup?
    var asRadioGroup:Bool = false
    var groupContainer:UIScrollView?
    
    var closeButtonText : String?
    var hideCloseButton : Bool = false
    
    var popUpDelegate:PopUpDelegate?
    var content : UIView?
    var controller : UIViewController?
    
    var fixedHeightSizePer:CGFloat? // = CGFloat(0.45)
    
    var selectedItemIndex: Int = -1
    var selectedItem: String = ""
    
    @IBOutlet weak var popupViewHeightConstr: NSLayoutConstraint!
    
    @IBOutlet weak var containerBottomView: NSLayoutConstraint!
    
    var originalScrollViewHeigh : CGFloat?
    
    var formatterDate : String {
        // Get closure is optional if there is only get and not set
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yy"
            return formatter.string(from: datePicker!.date)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popupTitle.text = customTitle
        popupTitle.textColor = customTitleColor
        
        positiveButton.isHidden = true
        negativeButton.isHidden = true
        if let positiveButtonLabel = positiveButtonLabel {
            positiveButton.setTitle(positiveButtonLabel, for: .normal)
            positiveButton.isHidden = false
        }
        
        if let negativeButtonLabel = negativeButtonLabel {
            negativeButton.setTitle(negativeButtonLabel, for: .normal)
            negativeButton.isHidden = false
        }
        
        if negativeButton.isHidden && positiveButton.isHidden {
            buttonContainer.isHidden = true
            buttonContainer.frame.size.height = 0.0
            buttonContainer.removeFromSuperview()
            DispatchQueue.main.async {
                self.containerBottomView.constant = 15
                self.container.layoutIfNeeded()
            }
        }
        
        indicator.isHidden = true
        indicator.hidesWhenStopped = true
        if isWebUrl {
            
            if( webView == nil ) {
                if let wkWebConfig = wkWebConfig {
                    webView = WKWebView(frame: container.bounds, configuration: wkWebConfig)
                } else {
                    webView = WKWebView()
                }
                //fixedHeightSizePer = 0.85
            }
            webView?.contentMode = contentMode
            
            if let webUrlPage = self.webUrlPage {
                let sscapedwebUrlPage = webUrlPage.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                if let scapedwebUrlPage = sscapedwebUrlPage {
                    debugPrint("webUrlPage: [\(scapedwebUrlPage)]")
                    let url = URL(string: scapedwebUrlPage)
                    debugPrint("url: [\(String(describing: url))]")
                    if let ourl = url {
                        let nsurl = NSURLRequest(url: ourl)
                        debugPrint("nsurl: [\(nsurl)]")
                        webView?.load(nsurl as URLRequest)
                    }
                }
                //webView?.load(NSURLRequest(url: NSURL(string: webUrlPage)! as URL) as URLRequest)
            }
            //webView?.delegate = self
            webView?.navigationDelegate = self
                
            webView?.frame = container.bounds
            webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            container.addSubview(webView!)
            container.sizeToFit()
            indicator.isHidden = false
            indicator.startAnimating()
        }
        
        if isDatePicker {
            datePicker = UIDatePicker(frame: container.bounds)
            datePicker?.datePickerMode = .date
            if let cDate = cDate {
                datePicker?.date = cDate
            }
            
            if maxDate == nil {
                datePicker?.maximumDate = Date()
            } else{
                datePicker?.maximumDate = maxDate
            }
            
            if minDate != nil {
                datePicker?.minimumDate = minDate
            }
            container.addSubview(datePicker!)
            container.sizeToFit()
            datePicker?.translatesAutoresizingMaskIntoConstraints = false
            //closeButton.frame.size.width = 30
            NSLayoutConstraint.activate([
                (datePicker?.centerYAnchor.constraint(equalTo: container.centerYAnchor))!,
                (datePicker?.centerXAnchor.constraint(equalTo: container.centerXAnchor))!
            ])
            /*
            (datePicker?.leadingAnchor.constraint(equalTo: container.leadingAnchor))!,
            (datePicker?.trailingAnchor.constraint(equalTo: container.trailingAnchor))!,
            (datePicker?.topAnchor.constraint(equalTo: container.topAnchor))!,
            (datePicker?.bottomAnchor.constraint(equalTo: container.bottomAnchor))!
             */
            
            fixedHeightSizePer = 0.45
        } else if !popupArray.isEmpty {
            chooser = true;
            
            if (asRadioGroup) {
                groupContainer = UIScrollView(frame: container.bounds)
                groupContainer?.isScrollEnabled = true
                
                groupContainer?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                container.addSubview(groupContainer!)
                //container.sizeToFit()
                groupContainer?.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    (groupContainer?.leadingAnchor.constraint(equalTo: container.leadingAnchor))!,
                    (groupContainer?.trailingAnchor.constraint(equalTo: container.trailingAnchor))!,
                    (groupContainer?.topAnchor.constraint(equalTo: container.topAnchor))!,
                    (groupContainer?.bottomAnchor.constraint(equalTo: container.bottomAnchor))!,
                    (groupContainer?.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 1.0))!,
                    (groupContainer?.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: 1.0))!
                ])
            
                radioGroup = RadioGroup(titles: popupArray)
                radioGroup?.frame = groupContainer?.frame as! CGRect
                radioGroup?.selectedIndex = 0
                selectedItemIndex = 0
                selectedItem = popupArray[selectedItemIndex]
                radioGroup?.addTarget(self, action: #selector(radioOptionSelected), for: .valueChanged)
                radioGroup?.tintColor = UIColor(named: "nonSelectedText")
                radioGroup?.titleColor = UIColor(named: "colorPrimaryDark")
                radioGroup?.selectedColor = UIColor(named: "nonSelectedText")
                
                //radioGroup?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                groupContainer?.addSubview(radioGroup!)
                radioGroup?.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    (radioGroup?.leadingAnchor.constraint(equalTo: groupContainer!.leadingAnchor))!,
                    //(radioGroup?.trailingAnchor.constraint(equalTo: groupContainer!.trailingAnchor))!,
                    (radioGroup?.topAnchor.constraint(equalTo: groupContainer!.topAnchor))!,
                    (radioGroup?.widthAnchor.constraint(equalTo: groupContainer!.widthAnchor, multiplier: 1.0))!
                ])
                
                /*
                if let size = radioGroup?.frame.size {
                    groupContainer.contentSize = size
                }
                 */
                let itemSize = CGFloat((radioGroup?.buttonSize ?? 1.0) * CGFloat(popupArray.count))
                let itemSizeSpacing = CGFloat((radioGroup?.spacing ?? 1.0) * 1.5 * CGFloat(popupArray.count))
                let effectiveRadiosize = CGFloat(itemSize + itemSizeSpacing)
                groupContainer?.contentSize = CGSize(width: container.frame.width, height: effectiveRadiosize)
                radioGroup?.frame = CGRect(x:0, y:0, width: container.frame.width, height: effectiveRadiosize)
                
                debugPrint("itemSize: \(itemSize)")
                debugPrint("itemSizeSpacing: \(itemSizeSpacing)")
                debugPrint("effectiveRadiosize: \(effectiveRadiosize)")
                
                fixedHeightSizePer = 0.65
            } else{
                myPopupButton = UIPickerView(frame: container.bounds)
                myPopupButton?.delegate = self
                myPopupButton?.dataSource = self
                myPopupButton?.selectRow(selectedIndex, inComponent: 0, animated: true)
                container.addSubview(myPopupButton!)
                container.sizeToFit()
                myPopupButton?.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    (myPopupButton?.leadingAnchor.constraint(equalTo: container.leadingAnchor))!,
                    (myPopupButton?.trailingAnchor.constraint(equalTo: container.trailingAnchor))!,
                    (myPopupButton?.topAnchor.constraint(equalTo: container.topAnchor))!,
                    (myPopupButton?.bottomAnchor.constraint(equalTo: container.bottomAnchor))!
                ])
             
                fixedHeightSizePer = 0.45
            }
            
            /*//closeButton.frame.size.width = 30
            NSLayoutConstraint.activate([
                (myPopupButton?.leadingAnchor.constraint(equalTo: container.leadingAnchor))!,
                (myPopupButton?.trailingAnchor.constraint(equalTo: container.trailingAnchor))!,
                (myPopupButton?.topAnchor.constraint(equalTo: container.topAnchor))!,
                (myPopupButton?.bottomAnchor.constraint(equalTo: container.bottomAnchor))!
            ])
             */
            //fixedHeightSizePer = 0.45
        } else {
            if let controller = self.controller {
                
                //if self.fixedHeightSizePer != nil {
                //    controller.view.frame = container.bounds
                //}
                
                //container.frame.size.height = controller.view.frame.height
                //controller.view.frame = container.bounds
                //if self.fixedHeightSizePer != nil {
                //    controller.view.frame = container.bounds
                //} else {
                    //container.frame.size.height = controller.view.frame.height
                //}
                controller.view.frame = container.bounds
                controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                addChild(controller)
                container.addSubview(controller.view)
                controller.didMove(toParent: self)
                
                if self.fixedHeightSizePer == nil {
                    //container.sizeToFit()
                }
            } else if let abContent = content {
                abContent.frame = container.bounds
                abContent.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                container.addSubview(abContent)
                container.sizeToFit()
            }
        }
        
        if let fixedHeightSizePer = self.fixedHeightSizePer {
            //popUpView.frame.size.height = CGFloat(self.view.frame.height * fixedHeightSizePer)
            popupViewHeightConstr = popupViewHeightConstr.changeMultiplier(multiplier: fixedHeightSizePer)
        } else {
            //popUpView.frame.size.height = container.frame.size.height + 110.0
        }
        
        //popUpView.sizeToFit()
        
        closeButton.isHidden = hideCloseButton
        if let closeButtonText = closeButtonText {
            closeButton.setTitle(closeButtonText, for: .normal)
            closeButton.setTitleColor(UIColor(named: "colorPrimaryDark"), for: .normal)
            closeButton.setImage(nil, for: .normal)
            closeButton.sizeToFit()
            
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            //closeButton.frame.size.width = 30
            /*
            NSLayoutConstraint.activate([
                //closeButton.leadingAnchor.constraint(equalTo: popupTitle.trailingAnchor),
                closeButton.trailingAnchor.constraint(equalTo: popUpView.trailingAnchor, constant: -40),
                closeButton.topAnchor.constraint(equalTo: popUpView.topAnchor, constant: 20)
                //closeButton.bottomAnchor.constraint(equalTo: picker.topAnchor)
            ])
             */
        }
        
        let pcolor = UIColor(named: "nonSelectedText")!
        container.addTopBorder(with: pcolor, andWidth: 1.0)
        container.addBottomBorder(with: pcolor, andWidth: 1.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                                object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)),
                                                name: UIResponder.keyboardWillHideNotification,
                                                object: nil)
    }
    
    
    @objc func keyboardWillShow(notification:NSNotification) {
        print("On keyboardWillShow")
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height / 2, right: 0)
        container.contentInset = contentInsets
        container.scrollIndicatorInsets = contentInsets
        //scrollView.contentSize = CGSize(width: view.frame.width, height: originalScrollViewHeigh! + 5.0)
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        print("On keyboardWillHide")
        if let originalScrollViewHeigh = self.originalScrollViewHeigh {
            container.contentInset = .zero
            container.scrollIndicatorInsets = .zero
            container.contentSize = CGSize(width: container.frame.width, height: originalScrollViewHeigh)
        }
    }
    
    func setWebUrl(surl: String) {
        self.webUrlPage = surl
        self.isWebUrl = true
    }
    
    func setWebViewObj(wv: WKWebView) {
        self.webView = wv
        self.isWebUrl = true
    }
    
    override func viewWillLayoutSubviews(){
        super.viewWillLayoutSubviews()
        originalScrollViewHeigh = container.frame.height
        if let originalScrollViewHeigh = self.originalScrollViewHeigh {
            container.contentSize = CGSize(width: container.frame.width, height: originalScrollViewHeigh)
        }
        
        if asRadioGroup {
            if let fixedHeightSizePer = self.fixedHeightSizePer {
                let rheight = (radioGroup?.frame.height)!
                let cheight = container.frame.height
                let gcheight = (groupContainer?.frame.height)!
                debugPrint("rheight: \(rheight)")
                debugPrint("cheight: \(cheight)")
                debugPrint("gcheight: \(gcheight)")
                if rheight < cheight {
                    self.fixedHeightSizePer = ((rheight * fixedHeightSizePer) / cheight)  + 0.15
                    debugPrint("New fixedHeightSizePer: \(self.fixedHeightSizePer)")
                    popupViewHeightConstr = popupViewHeightConstr.changeMultiplier(multiplier: fixedHeightSizePer)
                    /*
                    if( gcheight <= rheight ) {
                        groupContainer?.frame = CGRect(x:0, y:0, width: (groupContainer?.frame.width)!, height: container.frame.height)
                        groupContainer?.frame = container.frame
                        groupContainer?.layoutIfNeeded()
                    }
                    */
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return popupArray.count
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        selectedItemIndex = row
        return popupArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedItemIndex = row
        selectedItem = popupArray[row]
    }
    
    @objc func radioOptionSelected() {
        if let sindex = radioGroup?.selectedIndex {
            selectedItemIndex = sindex
        }
        debugPrint("on radioOptionSelected: \(selectedItemIndex)")
        selectedItem = popupArray[selectedItemIndex]
    }
    
    @IBAction func closePopUp(_ sender: UIButton) {
        if(chooser) {
            if let observerId = observerId {
                NotificationCenter.default.post(name: observerId, object: -1)
            }
        } else if let popUpDelegate = self.popUpDelegate {
            popUpDelegate.onCloseAction(observerId: self.observerId,controller: self.controller, popup: self)
        }
        dismiss(animated: true)
    }
    
    @IBAction func onPossitive(_ sender: Any) {
        if(chooser) {
            if let observerId = observerId {
                NotificationCenter.default.post(name: observerId, object: selectedItemIndex)
            }
        } else if(isDatePicker) {
            if let observerId = observerId {
                NotificationCenter.default.post(name: observerId, object: formatterDate)
            }
        } else if let popUpDelegate = self.popUpDelegate {
            popUpDelegate.onPossitiveAction(observerId: self.observerId,controller: self.controller, popup: self)
            // Delegating the dismiss operation to the onPossitiveAction handler for now
            return
        }
        dismiss(animated: true)
    }
    
    
    @IBAction func onNegative(_ sender: Any) {
        if(chooser) {
            if let observerId = observerId {
                NotificationCenter.default.post(name: observerId, object: -1)
            }
        } else if let popUpDelegate = self.popUpDelegate {
            popUpDelegate.onNegativeAction(observerId: self.observerId,controller: self.controller, popup: self)
        }
        dismiss(animated: true)
    }
        
    /*
    // MARK: WKWebView Delegate methods
    */
    
    // Equivalent of shouldStartLoadWithRequest
    @available(iOS 13.0, *)
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        debugPrint("Webview decidePolicyFor: \(navigationAction.navigationType)")
        debugPrint("Webview URL: \(String(describing: navigationAction.request.url))")
        
        /*
         * Disabling this approach from here and use UrlsViewController by default
        if let webDomain = self.webDomain {
            let handlerInvoker : (WKNavigationActionPolicy) -> Void = { action in
                decisionHandler(action, preferences)
            }
            handlerPolicyNavigationDomainCase(webDomain: webDomain, webView: webView, navigationAction: navigationAction, handlerInvoker: handlerInvoker)
            
            return
        }
         */
        
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
        
        /*
         * Disabling this approach from here and use UrlsViewController by default
        if let webDomain = self.webDomain {
            let handlerInvoker : (WKNavigationActionPolicy) -> Void = { action in
                decisionHandler(action)
            }
            handlerPolicyNavigationDomainCase(webDomain: webDomain, webView: webView, navigationAction: navigationAction, handlerInvoker: handlerInvoker)
        }
        */
        
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
    }
    
    // Equivalent of webViewDidFinishLoad
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Webview did finish load")
        indicator.stopAnimating()
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
