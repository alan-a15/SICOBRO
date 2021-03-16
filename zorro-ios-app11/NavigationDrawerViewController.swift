//
//  UrlsViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 11/07/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit

struct MenuOption {
    let menu: String
    let controller: String
    let image: UIImage
}

class NavigationDrawerTableCell: UITableViewCell {
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var name: UILabel!
}

class NavigationDrawerViewController: AbstractUIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private static let staticMenus = [
        MenuOption(menu: "Tira de Ofertas", controller: TransitionsViews.comunidadRedController.rawValue, image: UIImage(named: "iconTira")!),
        MenuOption(menu: "Notificaciones", controller: TransitionsViews.comunicadoController.rawValue, image: UIImage(named: "iconBell")!),
        MenuOption(menu: "Preguntas frecuentes", controller: TransitionsViews.faqController.rawValue, image: UIImage(named: "iconQuestion")!),
        MenuOption(menu: "Legal", controller: TransitionsViews.comunicadoController.rawValue, image: UIImage(named: "iconPolicy")!),
        MenuOption(menu: "Cerrar sesión", controller: TransitionsViews.redLoginController.rawValue, image: UIImage(named: "iconLogout")!)]
    
    private let menus = NavigationDrawerViewController.staticMenus
    
    var handler: ((_: String, _: Bool) -> Void)? = nil
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menu = menus[indexPath.row]
        let cell : NavigationDrawerTableCell = tableView.dequeueReusableCell(withIdentifier: "menuCell") as! NavigationDrawerTableCell
        
        cell.name.text = menu.menu
        cell.icon.image = menu.image
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = menus[indexPath.row].controller
        if controller == TransitionsViews.redLoginController.rawValue {
            let defaults = UserDefaults.init(suiteName: RedDefaults.comunidadRed.rawValue)!
            
            defaults.removeObject(forKey: "noRed")
            defaults.removeSuite(named: RedDefaults.comunidadRed.rawValue)
            
            NotificationsManager.setNotificationsBadge(0)
            
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                try? FileManager.default.removeItem(at: dir.appendingPathComponent("TiraOfertas\(TipoTira.Adicional.rawValue).data"))
                
                try? FileManager.default.removeItem(at: dir.appendingPathComponent("TiraOfertas\(TipoTira.Default.rawValue).data"))
            }
        }
        
        handler?(menus[indexPath.row].controller, true)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        dismiss(animated: true, completion: nil)
    }
}
