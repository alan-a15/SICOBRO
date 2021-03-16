//
//  ContactUsViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 01/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit

class ContactUsViewController: AbstractUIViewController, UITableViewDataSource, UITableViewDelegate  {

    @IBOutlet weak var contactList: UITableView!
    
    var contactUsItems : [ContactUsItem] = []
    var itemHeight:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contactList.dataSource = self
        contactUsItems = [ContactUsItem]()
        let parsedJSON = JsonUtils.readJSONFromFile(fileName: "contactus")
        print("parsedJSON: \(parsedJSON ?? "--")")
        guard let jsonMenu = parsedJSON as? [[String: Any]] else {
              return
        }
        print("jsonMenu: \(jsonMenu)")
        
        for item in jsonMenu {
            print("Item FOUNDED: \(item["id"] as? String ?? "")")
            contactUsItems.append(ContactUsItem(item))
        }
        print("contactUsItems found: \(contactUsItems.count)")
        //contactList.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let frameSize:CGFloat = view.frame.height
        itemHeight = CGFloat(contactList.frame.height) / CGFloat(contactUsItems.count)
        print("[ContactUsViewController] Total height of screen: \(frameSize)")
        print("[ContactUsViewController] Height of contactList: \(contactList.frame.height)")
        print("[ContactUsViewController] Calculated Height \(itemHeight)")
        contactList.rowHeight = CGFloat(itemHeight)
        contactList.estimatedRowHeight = CGFloat(itemHeight)
        contactList.tableFooterView = UIView()
        contactList.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let frameSize:CGFloat = view.frame.height
        itemHeight = CGFloat(contactList.frame.height) / CGFloat(contactUsItems.count)
        print("[ContactUsViewController] Total height of screen: \(frameSize)")
        print("[ContactUsViewController] Height of contactList: \(contactList.frame.height)")
        print("[ContactUsViewController] Calculated Height \(itemHeight)")
        contactList.rowHeight = CGFloat(itemHeight)
        contactList.estimatedRowHeight = CGFloat(itemHeight)
        contactList.tableFooterView = UIView()
        contactList.reloadData()
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactUsItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = contactUsItems[indexPath.row]
        print("item row \(indexPath.row)")
        print("item id \(item.id)")
        print("item label \(item.label)")
        print("item item \(item.value)")
        print("item imageSrc \(item.imageSrc)")
        
        
        let cell : ContactMenuItem = self.contactList.dequeueReusableCell(withIdentifier: "contactItem")! as! ContactMenuItem
        cell.contactImg.image = UIImage(named: item.imageSrc)
        cell.contactLabel.text = item.label
        cell.layoutIfNeeded()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(actionItem))
        cell.tag = indexPath.row
        cell.addGestureRecognizer(tap)
        cell.isUserInteractionEnabled = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return itemHeight
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return itemHeight
    }
    
    @objc func actionItem(sender : UITapGestureRecognizer) {
        let contact = contactUsItems[sender.view!.tag]
        // Get action to be performed
        
        var appURL:URL?
        var appURLAlternative:URL?
        switch contact.id {
            case "mail":
                let email = contact.value
                appURL = URL(string: "mailto:\(email)")!
                break;
            
            case "whatsapp":
                let phoneNumber = contact.value
                appURL = URL(string: "https://api.whatsapp.com/send?phone=\(phoneNumber)")!
                break;
            
            case "fb":
                let username = contact.value
                appURL = URL(string: "fb://page/\(username)")!
                appURLAlternative = URL(string: "https://facebook.com/\(username)")
                break;
            
            case "web":
                let surl = contact.value
                appURL = URL(string: surl)!
                break;
            
            default:
                self.showAlert(message: "Opción no válida")
                return
        }
        
        if let appURL = appURL {
            openURL(appURL: appURL, type: contact.id, webAlternative: appURLAlternative)
        } else {
             self.showAlert(message: "URL inválida")
        }
    }
    
    private func openURL(appURL : URL, type: String, webAlternative: URL? = nil) {
        if(UIApplication.shared.canOpenURL(appURL)) {
            UIApplication.shared.open(appURL) { (result) in
                debugPrint("Result from \(type) call: [\(result)]")
            }
            // Alternative for less than ios 10
            //UIApplication.shared.openURL(appURL) Al
        } else {
            if let webAlternative = webAlternative {
                self.openURL(appURL: webAlternative, type: type, webAlternative: nil)
            } else {
                self.showAlert(message: "No fue posible abrir \(type).")
            }
        }
    }

}

class ContactMenuItem : UITableViewCell {
    
    @IBOutlet weak var contactImg: UIImageView!
    
    @IBOutlet weak var contactLabel: UILabel!
    
}
