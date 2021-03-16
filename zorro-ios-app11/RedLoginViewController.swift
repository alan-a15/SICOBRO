//
//  UrlsViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 11/07/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit
import TKFormTextField

class RedLoginViewController: ZorroAbstracUIViewController {
    
    private let appVersion: AppVersion = AppVersion()
    
    private var messageShowed = false
    
    @IBOutlet weak var backButton: UIImageView!
    
    @IBOutlet weak var tfRed: TKFormTextField!
    @IBOutlet weak var tfRedYear: TKFormTextField!
    @IBOutlet weak var tfRedMonth: TKFormTextField!
    @IBOutlet weak var btnLogin: CustomRoundedButton!
    
    @IBOutlet weak var errorMessage: UITextView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.appVersion.version = self.version
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let errorFont = UIFont.systemFont(ofSize: 12)
        
        tfRed.lineColor = UIColor.gray
        tfRed.selectedLineColor = UIColor.black
        tfRed.errorLabel.font = errorFont
        tfRed.errorColor = UIColor.red
        
        tfRedYear.lineColor = UIColor.gray
        tfRedYear.selectedLineColor = UIColor.black
        tfRedYear.errorLabel.font = errorFont
        tfRedYear.errorColor = UIColor.red
        
        tfRedMonth.lineColor = UIColor.gray
        tfRedMonth.selectedLineColor = UIColor.black
        tfRedMonth.errorLabel.font = errorFont
        tfRedMonth.errorColor = UIColor.red
        
        addBackButton(backButton)
        
        controlsEnabled(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkVersion(version, callback: checkLogged)
    }
    
    func loading(_ loading: Bool) {
        if (loading) {
            spinner.startAnimating()
            errorMessage.isHidden = true
            btnLogin.isHidden = true
            controlsEnabled(false)
        } else {
            spinner.stopAnimating()
        }
    }
    
    func controlsEnabled(_ enabled: Bool) {
        tfRed.isEnabled = enabled
        tfRedYear.isEnabled = enabled
        tfRedMonth.isEnabled = enabled
        btnLogin.isEnabled = enabled
    }
    
    func showWelcome() {
        if messageShowed { return }
        
        let customImagePopup = CustomImagePopup(frame: CGRect(x: 0, y: 0, width: view.frame.width - 10, height: view.frame.height / 2))
        customImagePopup.image = UIImage(named: "welcome_red")!
        customImagePopup.isHidden = true
        
        view.addSubview(customImagePopup)
        
        customImagePopup.popUpImageToFullScreen()
        
        messageShowed = true
    }
    
    func checkVersion(_ version: String, callback: @escaping () -> Void) {
        HttpRequest.httpPost("cliente/appversion", body: appVersion,
                             success: { (response) -> Void in
                                callback()
                             }, failure: { (code, response) -> Void in
                                self.errorMessage.text = response
                                    .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                                    .replacingOccurrences(of: "\\n", with: "\n")
                                self.errorMessage.isHidden = false
                             })
    }
    
    func checkLogged() {
        loading(false)
        controlsEnabled(true)
        
        if defaults.value(forKey: "noRed") != nil {
            print("logged!")
            
            performTransitionWithIdentifier(identifier: TransitionsViews.comunidadRedController.rawValue, destroyCurrentView: true)
        } else {
            showWelcome()
        }
    }
    
    func login(noRed: String, year: String, month: String) {
        HttpRequest.httpGet("cliente/validate/\(noRed)/\(year)/\(month)",
                            success: { (response) -> Void in
                                self.defaults.setValue(noRed, forKey: "noRed")
                                
                                let defaultsFirebase = UserDefaults.init(suiteName: RedDefaults.firebase.rawValue)!
                                
                                let fcmToken = defaultsFirebase.string(forKey: "FCMToken")
                                
                                HttpRequest.httpPost("cliente/fcmtoken/\(noRed)", body: fcmToken, success: { (response) in
                                    print("Saved token on server")
                                }, failure: { (code, response) in
                                    print("Couldn't save token on server")
                                })
                                
                                self.checkLogged()
                            }, failure: { (code, response) -> Void in
                                self.errorMessage.text = response
                                    .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                                    .replacingOccurrences(of: "\\n", with: "\n")
                                self.errorMessage.isHidden = false
                            }, always: { () in
                                self.btnLogin.isHidden = false
                                self.loading(false)
                                self.controlsEnabled(true)
                            })
    }
    
    @IBAction func btnLoginClick(_ sender: Any) {
        errorMessage.isHidden = true
        
        tfRed.error = nil
        tfRedYear.error = nil
        tfRedMonth.error = nil
        
        
        guard let noRed = tfRed.text, !noRed.isEmpty else {
            tfRed.error = "Debes llenar este campo"
            return
        }
        
        guard let year = tfRedYear.text, !year.isEmpty else {
            tfRedYear.error = "Debes llenar este campo"
            return
        }
        
        guard let month = tfRedMonth.text, !month.isEmpty else {
            tfRedMonth.error = "Debes llenar este campo"
            return
        }
        
        loading(true)
        controlsEnabled(false)
        spinner.startAnimating()
        
        checkVersion(version) { () in
            self.login(noRed: noRed, year: year, month: month)
        }
    }
}
