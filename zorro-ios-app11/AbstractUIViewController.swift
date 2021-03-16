//
//  AbstractUIViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 05/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit
import Alamofire

/// Enum
enum TransitionsViews : String {
    case setPinTransCustom = "setPinTransCustom"
    case SiCobroViewController = "SiCobroViewController"
    case pinLoginTrans = "pinLoginTrans"
    case firstLoginTrans = "firstLoginTrans"
    case setPinTransPwdChange = "setPinTransPwdChange"
    case redLoginController = "RedLoginViewController"
    case comunidadRedController = "ComunidadRedViewController"
    case comunicadoController = "ComunicadoViewController"
    case comunicadoDetailController = "ComunicadoDetailViewController"
    case faqController = "FaqViewController"
    case volanteViewController = "VolanteViewController"
    case findStoreViewController = "FindStoreViewController"
}

class AbstractUIViewController: UIViewController {

    //TO-DO Make these servcices singleton
    var sessionManager : SessionManager = SessionManager.getInstance()
    
    var userSession : UserInfoLoginResponse?
    
    var isActiveSession : Bool = true
    
    var keyboardActions : ExtensionKeyboardActions?
    
    var destroyCurrentView:Bool = false
    
    var campanaId: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userSession = sessionManager.loadUserSession()
        /*
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.hidesBarsOnTap = true
         */
        //navigationController?.setNavigationBarHidden(true, animated: false)
        
        
        //let statWindow = UIApplication.shared.value(forKey:"statusBarWindow") as! UIView
        /*
        let statusBar = UIApplication.shared.statusBarManage
        statusBar.backgroundColor = UIColor.clear
        let blur = UIBlurEffect(style:.dark)
        let visualeffect = UIVisualEffectView(effect: blur)
        visualeffect.frame = statusBar.frame
        //statusBar.addSubview(visualeffect)
        visualeffect.alpha = 0.5
        self.view.addSubview(visualeffect)
 */
        
        /*
        let statusBarFrame: CGRect
        if #available(iOS 13.0, *) {
            statusBarFrame = view.window?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
        } else {
            statusBarFrame = UIApplication.shared.statusBarFrame
        }
        let statusBarView = UIView(frame: statusBarFrame)
        statusBarView.backgroundColor = UIColor.black
        view.addSubview(statusBarView)
         */
        
        // This code is to set a fixes color to status bar and avoid views overlaps it
        if #available(iOS 13, *) {
            let statusBar = UIView(frame: (UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame)!)
            statusBar.backgroundColor = UIColor(named: "colorPrimaryDark")
            UIApplication.shared.keyWindow?.addSubview(statusBar)
        } else {
           // ADD THE STATUS BAR AND SET A CUSTOM COLOR
           let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
           if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
              statusBar.backgroundColor = UIColor(named: "colorPrimaryDark")
           }
           UIApplication.shared.statusBarStyle = .lightContent
        }
            
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.barStyle = .default
        self.navigationController?.navigationBar.isTranslucent = true
        //self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.navigationController?.hidesBarsOnTap = false
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /**
     *
     */
    func showAlert(message: String, tittle: String = "") {
        // create the alert
        let alert = UIAlertController(title: tittle, message: message, preferredStyle: UIAlertController.Style.alert)

        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func goToSiCobroHomePage() {
        print("On goToSiCobroHomePage")
        _ = UIStoryboard(name: "Main", bundle: nil)
        
        let containerViewController = SideMenuController(type: .SICOBRO_VIEW)
        self.navigationController!.pushViewController(containerViewController, animated: true)
    }
    
    func validateSessions(forwardToInitial : Bool = true,
                          destroyCurrentView: Bool = false) -> Bool {
            // If this method return false, the session expired cause passed 1 day at least
            //  So the preferences are invalidates by this method automatically if that condition
            //  is acomplished.
            sessionManager.validateLastLoginCredentials()

            self.destroyCurrentView = destroyCurrentView
        
            if (sessionManager.isUserLoggedIn()) {
                if(!sessionManager.isUserActivated()) {
                    // Unsupported case
                    showAlert(message: "User deactivated. Unsupported case")
                } else if (sessionManager.isChangePasswordRequired() ) {
                    // Forward to SetPin
                    performTransitionWithIdentifier(identifier: "setPinTransCustom")
                } else {
                    if (sessionManager.isUserLoggedInWithPin()) {
                        isActiveSession = sessionManager.validateActiveSession()
                        if(isActiveSession) {
                            if(forwardToInitial) {
                                // Forward to SiCobro home page
                                //showAlert(message: "SiCobro Home Page in Progress")
                                performTransitionWithIdentifier(identifier: "SiCobroViewController")
                            }
                            return true
                        } else {
                            // TIMEDOUT_SESSION
                            // Forward to PinLogin due to TimeOut
                            performTransitionWithIdentifier(identifier: "pinLoginTrans")
                        }
                    } else {
                        // Forward to PinLogin
                        performTransitionWithIdentifier(identifier: "pinLoginTrans")
                    }
                }
            } else {
                // Forward to FirstLogin
                performTransitionWithIdentifier(identifier: "firstLoginTrans")
            }
            return false

    }
    
    func performTransitionWithIdentifier(identifier: String, destroyCurrentView: Bool) {
        self.destroyCurrentView = destroyCurrentView
    
        performTransitionWithIdentifier(identifier: identifier)
    }
    
    func performTransitionWithIdentifier(identifier: String, storyboard: String = "Main") {
        /*
        let loginStoryboard = UIStoryboard(name: storyboard , bundle: nil)
        let firstLogin = loginStoryboard.instantiateViewController(withIdentifier: "firstLogin") as! FirstLoginViewController
        self.present(firstLogin, animated: true)
         */
        
        self.performSegue(withIdentifier: identifier, sender: nil)
        
        /*
        print("On performTransitionWithIdentifier")
        let loginStoryboard = UIStoryboard(name: storyboard , bundle: nil)
        let target = loginStoryboard.instantiateViewController(withIdentifier: identifier)
        self.navigationController!.pushViewController(target, animated: true)
        */
    }
    
    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let transition = TransitionsViews(rawValue: identifier)
        
        switch transition {
        case .setPinTransCustom:
            let viewControllerToInsert = storyboard.instantiateViewController(
                withIdentifier: "setPin") as! SetPinViewController
            // create an object using the current navigation stack
            var navStackArray: [UIViewController]! = self.navigationController?.viewControllers
            navStackArray.append(viewControllerToInsert)
            self.navigationController?.setViewControllers(navStackArray, animated: true)
            break
            
        case .setPinTransPwdChange:
            let target = storyboard.instantiateViewController(withIdentifier: "setPin") as! SetPinViewController
            target.isPwdChange = true
            self.navigationController!.pushViewController(target, animated: true)
            break
            
        case .SiCobroViewController:
            goToSiCobroHomePage()
            break
            
        case .pinLoginTrans:
            let target = storyboard.instantiateViewController(withIdentifier: "pinLogin") as! PinLoginViewController
            self.navigationController!.pushViewController(target, animated: true)
            break
            
        case .firstLoginTrans:
            let target = storyboard.instantiateViewController(withIdentifier: "firstLogin") as! FirstLoginViewController
            self.navigationController!.pushViewController(target, animated: true)
            if (self.destroyCurrentView) {
                var navStackArray: [UIViewController]! = self.navigationController?.viewControllers
                navStackArray.remove(at: navStackArray.count - 2)
                self.navigationController?.setViewControllers(navStackArray, animated: true)
            }
            break
            
        case .redLoginController:
            let target = storyboard.instantiateViewController(withIdentifier: "redLogin") as! RedLoginViewController
            self.navigationController!.pushViewController(target, animated: true)
            if (self.destroyCurrentView) {
                var navStackArray: [UIViewController]! = self.navigationController?.viewControllers
                navStackArray.remove(at: navStackArray.count - 2)
                self.navigationController?.setViewControllers(navStackArray, animated: true)
            }
            break
            
        case .comunidadRedController:
            let target = storyboard.instantiateViewController(withIdentifier: "comunidadRed") as! TiraOfertasViewController
            self.navigationController!.pushViewController(target, animated: false)
            if (self.destroyCurrentView) {
                var navStackArray: [UIViewController]! = self.navigationController?.viewControllers
                navStackArray.remove(at: navStackArray.count - 2)
                self.navigationController?.setViewControllers(navStackArray, animated: false)
            }
            break
            
        case .comunicadoController:
            let target = storyboard.instantiateViewController(withIdentifier: "comunicado") as! ComunicadoViewController
            self.navigationController!.pushViewController(target, animated: false)
            if (self.destroyCurrentView) {
                var navStackArray: [UIViewController]! = self.navigationController?.viewControllers
                navStackArray.remove(at: navStackArray.count - 2)
                self.navigationController?.setViewControllers(navStackArray, animated: false)
            }
            break
            
        case .comunicadoDetailController:
            let target = storyboard.instantiateViewController(withIdentifier: "comunicadoDetail") as! ComunicadoDetailViewController
            target.campanaId = self.campanaId
            self.navigationController!.pushViewController(target, animated: true)
            if (self.destroyCurrentView) {
                var navStackArray: [UIViewController]! = self.navigationController?.viewControllers
                navStackArray.remove(at: navStackArray.count - 2)
                self.navigationController?.setViewControllers(navStackArray, animated: true)
            }
            break
            
        case .faqController:
            let target = storyboard.instantiateViewController(withIdentifier: "faq") as! FaqViewController
            self.navigationController!.pushViewController(target, animated: true)
            if (self.destroyCurrentView) {
                var navStackArray: [UIViewController]! = self.navigationController?.viewControllers
                navStackArray.remove(at: navStackArray.count - 2)
                self.navigationController?.setViewControllers(navStackArray, animated: true)
            }
            break
            
        case .volanteViewController:
            let target = storyboard.instantiateViewController(withIdentifier: "volante") as! VolanteViewController
            self.navigationController!.pushViewController(target, animated: true)
            if (self.destroyCurrentView) {
                var navStackArray: [UIViewController]! = self.navigationController?.viewControllers
                navStackArray.remove(at: navStackArray.count - 2)
                self.navigationController?.setViewControllers(navStackArray, animated: true)
            }
            break
            
        case .findStoreViewController:
            let target = storyboard.instantiateViewController(withIdentifier: "findStore") as! FindStoreViewController
            self.navigationController!.pushViewController(target, animated: true)
            if (self.destroyCurrentView) {
                var navStackArray: [UIViewController]! = self.navigationController?.viewControllers
                navStackArray.remove(at: navStackArray.count - 2)
                self.navigationController?.setViewControllers(navStackArray, animated: true)
            }
            break
            
        default:
            super.performSegue(withIdentifier: identifier, sender: sender)

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if(segue.identifier == "pinLoginTrans") {
            let view : PinLoginViewController = segue.destination as! PinLoginViewController
            view.isTimedOut = !self.isActiveSession
        }
        
        if(segue.identifier == "MenuSegue") {
            let view : HomeMenuViewController = segue.destination as! HomeMenuViewController
            
        }
    }
    
    func genericOnFailure(error:AFError?, response:HTTPURLResponse?) {
        print("error \(String(describing: error))")
        print("errorDescription \(String(describing: error?.errorDescription))")
        print("failedStringEncoding \(String(describing: error?.failedStringEncoding))")
        print("destinationURL \(String(describing: error?.destinationURL))")
        print("response \(String(describing: response))")
        print("statusCode \(String(describing: response?.statusCode))")
        showAlert(message: "Ocurrio un error invocando el servicio. Verifique su conexion de red. Error: \(String(describing: error?.errorDescription))")
    }
    
    weak var currentInputResponder: IconedUITextField? = nil
    
    func getGenericFormToolbar(addNavButtons : Bool = false) -> UIToolbar {
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: view.frame.width, height: 30)))
        let flexspage = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        
        let doneBtn = UIBarButtonItem(title: "Finalizar", style: .done, target: self, action: #selector(doneButton))
        
        if( addNavButtons ) {
            let prevBtn = UIBarButtonItem(title: "Ant.", style: .done, target: self, action: #selector(prevButton))
            let sigBtn = UIBarButtonItem(title: "Sig.", style: .done, target: self, action: #selector(nextButton))
            toolbar.setItems([prevBtn, sigBtn, flexspage, doneBtn], animated: false)
        } else {
            toolbar.setItems([flexspage, doneBtn], animated: false)
        }
        //toolbar.setItems([prevBtn, sigBtn, flexspage, doneBtn], animated: false)
        //toolbar.setItems([flexspage, doneBtn], animated: false)
        toolbar.sizeToFit()
        return toolbar
    }
    
    @objc func doneButton(sender: UIBarButtonItem) {
        self.view.endEditing(true)
        if let keyboardActions  = keyboardActions {
            keyboardActions.keybDoneButton()
        }
    }
    
    @objc func prevButton(sender: UIBarButtonItem) {
        if let keyboardActions  = keyboardActions {
            keyboardActions.keybPrevButton(sender: sender)
        }
    }
    
    @objc func nextButton(sender: UIBarButtonItem) {
        if let keyboardActions  = keyboardActions {
            keyboardActions.keybNextButton(sender: sender)
        }
    }
}

protocol ExtensionKeyboardActions {
    func keybDoneButton()
    func keybPrevButton(sender: UIBarButtonItem)
    func keybNextButton(sender: UIBarButtonItem)
}

extension UIView {
    func addTopBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: borderWidth)
        self.addSubview(border)
    }

    func addBottomBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        border.frame = CGRect(x: 0, y: self.frame.size.height - borderWidth, width: self.frame.size.width, height: borderWidth)
        self.addSubview(border)
    }
}

extension AbstractUIViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Verify all the conditions
        if let iconedUITextField = textField as? IconedUITextField {
            print("Validated iconed: \(iconedUITextField)")
            return iconedUITextField.verifyFields(shouldChangeCharactersIn: range, replacementString: string)
        }
        return true
    }
}
