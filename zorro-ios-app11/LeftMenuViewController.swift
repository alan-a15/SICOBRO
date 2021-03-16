//
//  LeftMenuViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 22/03/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit
import WebKit

enum MenuType {
    case BANNERS, SICOBRO
}

/// Enum
enum CustomMenuItemId : String {
    case mainMenu = "mainMenu"
    case start = "start"
    case contactus = "contactus"
    case logout = "logout"
    case deleteSession = "deleteSession"
}

class LeftMenuViewController: AbstractUIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var delegate: LeftMenuViewControllerDelegate?
    var centerController: CenterMenuViewController?

    @IBOutlet weak var sideMenu: UITableView!
    @IBOutlet weak var hideMenu: UIImageView!
    @IBOutlet weak var menuImgHeader: UIImageView!
    
    var menuItems : [SideMenuItem] = []
    
    var menuType : MenuItemSection?
    private var itemBackgrouncolor:UIColor?
    
    @IBOutlet weak var versionTxt: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sideMenu.dataSource = self
        menuItems = [SideMenuItem]()
        let fileName = Environment.isDev() ? "sideMenu_dev" : "sideMenu_prod"
        let parsedJSON = JsonUtils.readJSONFromFile(fileName: fileName)
        print("parsedJSON: \(String(describing: parsedJSON))")
        guard let jsonMenu = parsedJSON as? [[String: Any]] else {
              return
        }
        print("jsonMenu: \(jsonMenu)")
        
        for item in jsonMenu {
            print("Item FOUNDED: \(item["id"] as? String ?? "")")
            let menuitem:SideMenuItem = SideMenuItem(item)
            guard menuitem.showsIn.contains(menuType) else {
                print("menuItem \(menuitem.id) Skipped ")
                continue
            }
            menuItems.append(menuitem)
        }
        print("MenuItems found: \(menuItems.count)")
        sideMenu.tableFooterView = UIView()
        sideMenu.reloadData()
        
        switch menuType {
            case .BANNERS:
                menuImgHeader.image = UIImage(named: "slogan_white")
                itemBackgrouncolor = UIColor(named: "drawer_background2")
                break;
            
            case .SICOBRO:
                menuImgHeader.image = UIImage(named: "logo_sicobro_menu")
                menuImgHeader.frame = CGRect(x: 0, y: 0,
                                             width: CGFloat(self.view.frame.width / 3.0),
                                             height: menuImgHeader.frame.height)
                itemBackgrouncolor = UIColor(named: "drawer_background1")
                break;
            
            default:
                itemBackgrouncolor = .black
                break;
        }
        if #available(iOS 13, *) {
            self.view.backgroundColor = itemBackgrouncolor
            self.sideMenu.backgroundColor = itemBackgrouncolor
        } else {
            self.view.backgroundColor = itemBackgrouncolor
            if let bview = self.sideMenu.backgroundView {
                bview.backgroundColor = itemBackgrouncolor
            }
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(callCollapse))
        hideMenu.addGestureRecognizer(tap)
        hideMenu.isUserInteractionEnabled = true
        
        view.frame.size.width = view.frame.width - 80
        
        setVersionNumber()
    }
    
    /*
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = itemBackgrouncolor
        self.sideMenu.backgroundColor = itemBackgrouncolor
    }
     */
    
    @objc func callCollapse() {
        delegate?.collapse()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let menuItem = menuItems[indexPath.row]
        print("menuItem row \(indexPath.row)")
        print("menuItem id \(menuItem.id)")
        print("menuItem imag \(menuItem.imageSrc)")
        print("menuItem showsIn \(menuItem.showsIn)")
        
        let cell : LeftMenuItem = self.sideMenu.dequeueReusableCell(withIdentifier: "menuItem")! as! LeftMenuItem
        cell.itemMnImage.image = UIImage(named: menuItem.imageSrc)
        cell.itemMnLabel.text = menuItem.label
        cell.backgroundColor = itemBackgrouncolor
        cell.layoutIfNeeded()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(actionItem))
        cell.tag = indexPath.row
        cell.addGestureRecognizer(tap)
        cell.isUserInteractionEnabled = true
        
        if( CustomMenuItemId.init(rawValue: menuItem.id) == CustomMenuItemId.deleteSession && !Environment.isDev() ) {
            cell.isHidden = true
        }
        return cell
    }
    
    @objc func actionItem(sender : UITapGestureRecognizer) {
        let menuItem = menuItems[sender.view!.tag]
        // Get action to be performed
        switch menuItem.type {
            case "URL":
                openUrlPopUp(menuItem: menuItem)
                break;
            case "CUSTOM":
                let item = CustomMenuItemId.init(rawValue: menuItem.id)
                switch item {
                    case .contactus:
                        let storyboard = UIStoryboard(name: "CustomPopup" , bundle: nil)
                        let contactUsView = storyboard.instantiateViewController(withIdentifier: "contactusView") as! ContactUsViewController
                        openCustomPopUp(menuItem: menuItem, view: contactUsView)
                        break
                    
                    case .logout:
                        sessionManager.closeSession()
                        self.navigationController?.popViewController(animated: true)
                        //self.navigationController?.popToRootViewController(animated: true)
                        break
                    
                    case .mainMenu:
                        if let homeController = centerController as? HomePageViewController {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let targetAction = FragmentSection.MENU.rawValue
                            let target = storyboard.instantiateViewController(withIdentifier: targetAction) as! SICobroViewController
                            homeController.floaty.close()
                            homeController.onSectionChange(target: target, fragmentSection: FragmentSection.MENU)
                            callCollapse()
                        }
                        break
                    
                    case .deleteSession:
                        if( Environment.isDev() ) {
                            debugPrint("Dev Mode: Delete session")
                            sessionManager.invalidatePreferences(clearAll: true)
                            self.showAlert(message: "Datos de Sesión borrados")
                        }
                        break
                    
                    case .start:
                        self.navigationController?.popToRootViewController(animated: true)
                        break
                
                    default:
                        print("Unsupported case")
                }
                break;
            default:
                break;
        }
    }
    
    func openUrlPopUp(menuItem : SideMenuItem) {
        let storyboard = UIStoryboard(name: "CustomPopup" , bundle: nil)
        // Forcing to unwrap the ViewController
        let popup = storyboard.instantiateInitialViewController() as! CustomPopUpViewController
        popup.customTitle = menuItem.label
        popup.setWebUrl(surl: menuItem.url!)
        popup.fixedHeightSizePer = 0.85
        
        self.present(popup, animated: true)
    }
    
    func openCustomPopUp(menuItem : SideMenuItem, view : UIViewController) {
        let storyboard = UIStoryboard(name: "CustomPopup" , bundle: nil)
        // Forcing to unwrap the ViewController
        let popup = storyboard.instantiateInitialViewController() as! CustomPopUpViewController
        popup.customTitle = menuItem.label
        //popup.fixedHeightSizePer = 0.60
        popup.controller = view
        
        self.present(popup, animated: true)
    }
    
    private func setVersionNumber(){
        let settings = JanoSettings.getSettingsInstance()
        let version = settings.getVisibleVersion()
        let versionMsg = "Version \(version)"
        versionTxt.text = versionMsg
    }
}



protocol LeftMenuViewControllerDelegate {
  func collapse()
}

class LeftMenuItem : UITableViewCell {
    @IBOutlet weak var itemMnImage: UIImageView!
    @IBOutlet weak var itemMnLabel: UILabel!
}

