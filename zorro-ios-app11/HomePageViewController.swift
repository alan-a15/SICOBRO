//
//  HomePageViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 08/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit
import Alamofire
import Floaty

class HomePageViewController: CenterMenuViewController, MenuHandler  {

    @IBOutlet weak var headerView: UIView!

    @IBOutlet weak var content: UIScrollView!
    
    var currentViewController:SICobroViewController?
    
    var headerViewController:HeaderViewController?
    
    var floaty = Floaty(size: 35.0)
    
    var originalScrollViewHeigh : CGFloat?
    
    @IBOutlet weak var containerView: RounderCornerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("In HomePageViewController viewDidLoad")
        
        self.menuHandler = self
        
        if(currentViewController == nil) {
            // Set the default: Menu
            let section = FragmentSection.MENU.rawValue
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let targetController = storyboard.instantiateViewController(withIdentifier: section) as! SICobroViewController
            targetController.parentController = self
            currentViewController = targetController
            switchController()
        }
        
        SectionSiCobro.prepareFabHandlers(controller: self)
        SectionSiCobro.LST_SECTION.forEach { (it) in
            floaty.addItem(item: it.fabItem)
        }
        floaty.buttonColor = UIColor(named: "colorPrimary")!
        floaty.plusColor = UIColor(named: "colorPrimaryDark")!
        
        let floatySize = getFloatySize()
        
        floaty.isHidden = false
        floaty.alpha = 0.0
        floaty.size = floatySize
        floaty.itemSize = floatySize - 5.0
        floaty.friendlyTap = true
        floaty.paddingX = 4.0
        floaty.paddingY = 0.0
        
        content.addSubview(floaty)
        //self.automaticallyAdjustsScrollViewInsets = true
        
        let pcolor = UIColor(named: "colorPrimary")!
        addTopBorder(with: pcolor, andWidth: 2.0)
        addBottomBorder(with: pcolor, andWidth: 2.0)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground),
                                       name: UIApplication.willEnterForegroundNotification, object: nil)
    
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground),
                                       name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    func getFloatySize() -> CGFloat {
        switch UIScreen.main.nativeBounds.height {
            case 1136:      // print("iPhone 5 or 5S or 5C")
                return 45.0
            /*
            case 1334:
                return .iPhones_6_6s_7_8
            case 1792:
                return .iPhone_XR_11
            case 1920, 2208:
                return .iPhones_6Plus_6sPlus_7Plus_8Plus
            case 2426:
                return .iPhone_11Pro
            case 2436:
                return .iPhones_X_XS
            case 2688:
                return .iPhone_XSMax_ProMax */
            default:
                return 56.0
        }
    }


    @objc func appMovedToBackground() {
        print("App moved to Background!")
        self.view.endEditing(true)
    }

    @objc func appMovedToForeground() {
        print("App moved to Foreground!")
        // This should validate the session when the view appears.
        self.validateSessions(forwardToInitial: false, destroyCurrentView: true)
    }
    
    func addTopBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        border.frame = CGRect(x: 0, y: 0, width: containerView.frame.size.width, height: borderWidth)
        containerView.addSubview(border)
    }

    func addBottomBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        border.frame = CGRect(x: 0, y: containerView.frame.size.height - borderWidth, width: containerView.frame.size.width, height: borderWidth)
        containerView.addSubview(border)
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                                object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)),
                                                name: UIResponder.keyboardWillHideNotification,
                                                object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("HomePageViewController: On viewWillDisappear")
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func keyboardWillShow(notification:NSNotification) {
        print("On keyboardWillShow")
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        content.contentInset = contentInsets
        content.scrollIndicatorInsets = contentInsets
        content.alwaysBounceVertical = false
        
        
        //content.contentSize = CGSize(width: view.frame.width, height: originalScrollViewHeigh! + 5.0)
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        print("On keyboardWillHide")
        if let originalScrollViewHeigh = self.originalScrollViewHeigh {
            content.contentInset = .zero
            content.scrollIndicatorInsets = .zero
            content.contentSize = CGSize(width: view.frame.width, height: originalScrollViewHeigh)
        }
    }
    
    override func viewWillLayoutSubviews(){
        super.viewWillLayoutSubviews()
        originalScrollViewHeigh = content.frame.height
        if let originalScrollViewHeigh = self.originalScrollViewHeigh {
            content.contentSize = CGSize(width: view.frame.width, height: originalScrollViewHeigh)
        }
    }
    
    /*
     *
     */
    func showFloatMenu(show: Bool) {
        print("On showFloatMenu")
        floaty.isHidden = !show
        let targetAlpha = show ? 1.0 : 0.0
        UIView.transition(with: self.floaty, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            self.floaty.alpha = CGFloat(targetAlpha)
        }, completion: nil)
    }
    
    /*
     *
     */
    func onSectionChange(target: SICobroViewController, fragmentSection: FragmentSection) {
        debugPrint("onSectionChange")
        debugPrint("target \(target)")
        debugPrint("currentViewController \(currentViewController)")
        // Remove current
        currentViewController?.dismiss(animated: true, completion: {
            debugPrint("Current controller dismissed")
        })
        currentViewController?.view.removeFromSuperview()
        currentViewController = target
        currentViewController?.parentController = self      // Ensure all SICobroViewController onSectionChange have parent controlles
        switchController()
        
        refreshFloatingMenu(section: fragmentSection)
    }
    
    /*
     *
     */
    func switchController() {
        if(!self.validateSessions(forwardToInitial: false, destroyCurrentView: true)) {
            return
        }
        
        debugPrint("switchController")
        debugPrint("currentViewController \(currentViewController)")
        guard let currentViewController = currentViewController else {
            return
        }
        addChild(currentViewController)
        currentViewController.view.frame = content.bounds
        //currentViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        UIView.transition(with: self.content, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            self.content.addSubview(currentViewController.view)
        }, completion: nil)
        currentViewController.didMove(toParent: self)
        
        print("List of subviews \(self.content.subviews.count)")
    }
    
    /*
     *
     */
    func refreshHeader(fragmentSection: FragmentSection) {
        if let headerViewController = self.headerViewController {
            headerViewController.refreshHeaderData(psection: fragmentSection)
        }
    }
    
    /*
     *
     */
    func refreshFloatingMenu(section : FragmentSection?) {
        debugPrint("On refreshFloatingMenu")
        if section == FragmentSection.MENU {
            showFloatMenu(show: false)
        } else {
            showFloatMenu(show: true)
            floaty.removeFromSuperview()
            content.addSubview(floaty)
            //floaty.layer.zPosition = .greatestFiniteMagnitude
        }
        
        /*
        floaty.items.forEach { (it) in
            debugPrint("Removing: \(it.title)")
            floaty.removeItem(item: it)
        }
        SectionSiCobro.getFabItems(currentSection: section).forEach { (item) in
            debugPrint("Adding: \(item.title)")
            floaty.addItem(item: item)
        }
        */
        SectionSiCobro.hideFabItem(currentSection: section)
    }
    
    func getMenuType() -> MenuItemSection {
        return MenuItemSection.SICOBRO
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "headerVc") {
            self.headerViewController = segue.destination as? HeaderViewController
        }
        super.prepare(for: segue, sender: sender)
    }
    
}
