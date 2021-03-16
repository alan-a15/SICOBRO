//
//  FirstLoginViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 03/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit
import Alamofire

extension FirstLoginViewController {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentInputResponder = textField as? IconedUITextField
        return true
    }
}

class FirstLoginViewController: AbstractAuthenticationViewController, ExtensionKeyboardActions {
    @IBOutlet weak var redidTxt: IconedUITextField!
    @IBOutlet weak var passwordTxt: IconedUITextField!
    @IBOutlet weak var userTxt: IconedUITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    @IBOutlet weak var forgotPwdBtn: UIView!
   
    @IBOutlet weak var titleLogin: UILabel!
    @IBOutlet weak var loginMessage: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var backButtonHeader: UIImageView!
    
    var isPwdChange = false
    var originalScrollViewHeigh : CGFloat?
    
    private let INPUT_SUBMIT_TAG = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        if(isPwdChange) {
            titleLogin.text = "Crear nuevo Password"
            loginMessage.text = "Hemos enviado al correo registrado la contraseña temporal de tu cuenta:"
            loginMessage.textColor = UIColor(named: "helperColor")
        } else {
            //titleLogin.setText(getString(R.string.login_title))
            //loginMessage.setText(getString(R.string.login_message))
        }
        
        self.redidTxt.leftImage = UIImage(named: "id")
        self.redidTxt.borderColor = UIColor(named: "colorPrimaryDark")
        self.redidTxt.cornerRadius = 6.0
        self.redidTxt.borderWidth = 1.0
        self.redidTxt.maxLength = 9
        self.redidTxt.leftPadding = 5.0
        self.redidTxt.maxLength = 9
        self.redidTxt.delegate = self
        self.redidTxt.returnKeyType = UIReturnKeyType.next
        //self.redidTxt.valueType = .currency
        //self.redidTxt.delegate = self
        //self.redidTxt.keyboardType = .numbersAndPunctuation
        
        self.userTxt.leftImage = UIImage(named: "user")
        self.userTxt.borderColor = UIColor(named: "colorPrimaryDark")
        self.userTxt.cornerRadius = 6.0
        self.userTxt.borderWidth = 1.0
        self.userTxt.leftPadding = 5.0
        self.userTxt.maxLength = 30
        self.userTxt.delegate = self
        self.userTxt.returnKeyType = UIReturnKeyType.next
        
        self.passwordTxt.leftImage = UIImage(named: "pass")
        self.passwordTxt.rightImage = UIImage(named: "hide_pass")
        self.passwordTxt.borderColor = UIColor(named: "colorPrimaryDark")
        self.passwordTxt.cornerRadius = 6.0
        self.passwordTxt.borderWidth = 1.0
        self.passwordTxt.leftPadding = 5.0
        //self.passwordTxt.rightPadding = 10.0
        self.passwordTxt.valueType = .password
        self.passwordTxt.tooglePassword = false
        self.passwordTxt.isSecureTextEntry = true
        self.passwordTxt.maxLength = 20
        self.passwordTxt.delegate = self
        self.passwordTxt.returnKeyType = UIReturnKeyType.done
        
        self.redidTxt.delegate = self
        self.userTxt.delegate = self
        //self.passwordTxt.delegate = self
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.backBarButtonItem?.title = "Banners"
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(confirmChangePassword))
        forgotPwdBtn.addGestureRecognizer(tap)
        forgotPwdBtn.isUserInteractionEnabled = true
        
        /*
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: view.frame.width, height: 30)))
        let flexspage = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn = UIBarButtonItem(title: "Finalizar", style: .done, target: self, action: #selector(doneButton))
        toolbar.setItems([flexspage,doneBtn], animated: false)
        toolbar.sizeToFit()
         */
        
        self.keyboardActions = self
        let toolbar = self.getGenericFormToolbar()
        
        self.redidTxt.inputAccessoryView = toolbar
        self.userTxt.inputAccessoryView = toolbar
        self.passwordTxt.inputAccessoryView = toolbar
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(back))
        backButtonHeader.addGestureRecognizer(tap1)
        backButtonHeader.isUserInteractionEnabled = true
        
        let customImagePopup = CustomImagePopup(frame: CGRect(x: 0, y: 0, width: view.frame.width - 10, height: view.frame.height / 2))
        customImagePopup.image = UIImage(named: "login_aviso")!
        customImagePopup.isHidden = true
        view.addSubview(customImagePopup)
        
        debugPrint("Validating if user has been logged in at least once.")
        if( !sessionManager.isUserHadFirstLogin() ) {
            debugPrint("User does not have their first login yet. Preparing popup")
            DispatchQueue.background(delay: 0.5, completion:{
                customImagePopup.popUpImageToFullScreen()
            })
        }
    }
    
    @objc func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    /*
    @objc func doneButton() {
        self.view.endEditing(true)
    }
   */
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.redidTxt.adjustFont()
        self.userTxt.adjustFont()
        self.passwordTxt.adjustFont()
    }
    
    override func viewWillLayoutSubviews(){
        super.viewWillLayoutSubviews()
        originalScrollViewHeigh = scrollView.frame.height
        scrollView.contentSize = CGSize(width: view.frame.width, height: originalScrollViewHeigh!)
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            currentInputResponder = nextResponder as? IconedUITextField
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            self.submitLogin(self.submitBtn)
        }
        return true
    }
    
    /**
    MARK: keyboard actions
     */
    func keybDoneButton() {
        if let responder = self.currentInputResponder {
            if responder.tag == INPUT_SUBMIT_TAG && self.submitBtn.isEnabled {
                self.submitLogin(self.submitBtn)
            }
        }
    }
    
    func keybPrevButton(sender: UIBarButtonItem) { }
    
    func keybNextButton(sender: UIBarButtonItem) { }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        debugPrint("FirstLoginViewController: viewWillAppear")
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                                object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)),
                                                name: UIResponder.keyboardWillHideNotification,
                                                object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("FirstLoginViewController: On viewWillDisappear")
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {
        print("On keyboardWillShow")
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        //scrollView.contentSize = CGSize(width: view.frame.width, height: originalScrollViewHeigh! + 5.0)
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        print("On keyboardWillHide")
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
        scrollView.contentSize = CGSize(width: view.frame.width, height: originalScrollViewHeigh!)
    }
    
    private func enableForm(enabled : Bool = true) {
        redidTxt.isEnabled = enabled
        userTxt.isEnabled = enabled
        passwordTxt.isEnabled = enabled
        
        submitBtn.isEnabled = enabled
        submitBtn.isHidden = !enabled
        indicator.isHidden = enabled
        enabled ? indicator.stopAnimating() : indicator.startAnimating()
    }

    @IBAction func submitLogin(_ sender: UIButton) {
        enableForm(enabled: false)
        
        guard let txtStr = redidTxt.text, !txtStr.isEmpty else {
            showAlert(message: "El RedId es requerido")
            enableForm(enabled: true)
            return
        }
        
        guard let usertxtStr = userTxt.text, !usertxtStr.isEmpty else {
            showAlert(message: "El usuario es requerido")
            enableForm(enabled: true)
            return
        }
        
        guard let ptxtStr = passwordTxt.text, !ptxtStr.isEmpty else {
            showAlert(message: "El Password es requerido")
            enableForm(enabled: true)
            return
        }
        
        // Additional validations
        //self.view.showToast(toastMessage: "Login en proceso", duration: 4.0)
        
        let request : LoginRequest = LoginRequest()
        request.redId = txtStr
        request.storePassword = ptxtStr
        request.storeUsername = usertxtStr
        
        // Get object with devide informaiton
        let deviceInfo = DeviceUtil.getDeviceInfo()
        request.deviceId = deviceInfo.deviceId
        request.deviceBrand = deviceInfo.deviceBrand
        request.deviceModel = deviceInfo.deviceModel
        request.deviceOSVersion = deviceInfo.deviceOSVersion
        
        authenticationService.performCredentialLogin(loginReq: request, callback: createLoginCallback())
    }
    
    
    private func createLoginCallback() -> RestCallback<LoginResponse> {
        let loginOnResponse : ((LoginResponse?) -> ())? = { response in
            print("response \(String(describing: response))")
            print("actionRequired \(String(describing: response?.actionRequired))")
            print("maskedEmail \(String(describing: response?.maskedEmail))")
            print("sessionToken \(String(describing: response?.sessionToken))")
            
            let userInfo : UserInfoLoginResponse = UserInfoLoginResponse()
            if( response != nil ) {
                userInfo.redId = self.redidTxt.text ?? ""
                userInfo.addDataFromLoginResponse(loginData: response!)

                // Create logged user in session
                self.sessionManager.createInitialUserSession(user: userInfo)
                
                // Store Session Timeout from JANO
                self.authenticationService.getSessionTimeout(callback: self.createTimeoutCallback())
            }
            
            print("Continue with forward")
            if( self.isPwdChange ) {
                //self.showAlert(message: "PWD Change flow: In progress")
                // Current credentials were correctly validated so
                self.performSegue(withIdentifier: "setPinTransPwdChange", sender: nil)
            } else {
                // TO-DO: Adapt this code
                /*
                if (sessionManager.isNewSiCobroUser()) {
                    showWelcomeToSiCobroDialog()
                    return
                }
                */

                // As first login, we need to send SMS Code to activate and redirect to SMS Input code Activity
                // Then, SMS Code should be validated and request for input Custom PIN Code
                //authHelper.createLocalTokenUser(mUser.username, mUser.storeid)
                if ( !self.sessionManager.isUserActivated() ) {
                    self.showAlert(message: "User not be Activated?")
                    // This is not supported anymore but leave this sectio just in case supports later.
                } else {
                    // If reached this point, then the device is activated.
                    if (self.sessionManager.isChangePasswordRequired()) {
                        // If reached this point, then the password need to be updated
                        self.goSetPin()
                    } else {
                        // If reached this point, then the device is activated and password is not needed to be updated
                        // Avoid requesting for password, going directly to FIRST_SESSION_ACTIVITY_CLASS
                        //targetActivity = PinLoginActivity::class.java
                        self.goToSiCobroHomePage()
                        var navStackArray: [UIViewController]! = self.navigationController?.viewControllers
                        navStackArray.remove(at: navStackArray.count - 2)
                        self.navigationController?.setViewControllers(navStackArray, animated: true)
                        return
                    }
                }
                self.enableForm(enabled: true)
            }
            //self.showAlert(message: "Login Response Action: \(response?.actionRequired)")
        }
        
        let loginApiError : ((ApiError)->())? =  { apiError in
            let smsg = "Ocurrio un error en Login"
            guard let msg = apiError.message else {
                self.showAlert(message: smsg)
                return
            }
            self.showAlert(message: "\(smsg): \(msg)")
            self.enableForm(enabled: true)
        }
        
        let loginOnFailure : ((AFError?,HTTPURLResponse?)->())? = { (error, response) in
            print("error \(String(describing: error))")
            print("errorDescription \(String(describing: error?.errorDescription))")
            print("failedStringEncoding \(String(describing: error?.failedStringEncoding))")
            print("destinationURL \(String(describing: error?.destinationURL))")
            
            print("response \(String(describing: response))")
            print("statusCode \(String(describing: response?.statusCode))")
            self.showAlert(message: "Error ocurred for login: \(String(describing: error?.errorDescription))")
            self.enableForm(enabled: true)
        }
        return RestCallback<LoginResponse>(onResponse: loginOnResponse, onApiError: loginApiError, onFailure: loginOnFailure)
    }
    
    /*
     *
     */
    private func createTimeoutCallback() -> RestCallback<Int> {
        let timeoutOnRespose : ((Int?) -> ())? = { response in
            print("response \(String(describing: response))")
            self.sessionManager.setTimeoutSession(timeoutInSeconds: response ?? 300)
        }
        
        let timeoutApiError : ((ApiError)->())? =  { apiError in
            let smsg = "Ocurrio un error obteniendo timeout desde Jano"
            guard let msg = apiError.message else {
                self.showAlert(message: smsg)
                return
            }
            print("\(smsg): \(msg)")
            self.sessionManager.setTimeoutSession()
        }
        
        let timeoutOnFailure : ((AFError?,HTTPURLResponse?)->())? = { (error, response) in
            print("error \(String(describing: error))")
            print("errorDescription \(String(describing: error?.errorDescription))")
            print("failedStringEncoding \(String(describing: error?.failedStringEncoding))")
            print("destinationURL \(String(describing: error?.destinationURL))")
            
            print("response \(String(describing: response))")
            print("statusCode \(String(describing: response?.statusCode))")
            self.sessionManager.setTimeoutSession()
        }
        
        return RestCallback<Int>(onResponse: timeoutOnRespose, onApiError: timeoutApiError, onFailure: timeoutOnFailure)
    }
    
    
    @IBAction func goBack(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    /*
     *
     */
    @objc func goSetPin() {
        print("On goSetPin")
        
        /*
        let loginStoryboard = UIStoryboard(name: "Main" , bundle: nil)
        let setPinController = loginStoryboard.instantiateViewController(withIdentifier: "setPin") as! SetPinViewController
        self.present(setPinController, animated: true)
         */
        
        self.performSegue(withIdentifier: "setPinSegue1", sender: nil)
    }
    
    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        super.performSegue(withIdentifier: identifier, sender: sender)
        
        var navStackArray: [UIViewController]! = self.navigationController?.viewControllers
         
         navStackArray.remove(at: navStackArray.count - 2)
        
        self.navigationController?.setViewControllers(navStackArray, animated: true)
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
