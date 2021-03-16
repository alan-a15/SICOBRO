//
//  UrlsViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 11/07/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit
import Kingfisher
import ImageViewer_swift
import Lightbox

class VolanteTableCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var preview: UIImageView!
}

class VolanteViewController: AbstractUIViewController, UITableViewDelegate, UITableViewDataSource {
    private var volantes = [Volante]()
    
    private let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(back))
        backButton.addGestureRecognizer(tap1)
        backButton.isUserInteractionEnabled = true
        
        refreshControl.attributedTitle = NSAttributedString(string: "Desliza hacia abajo para actualizar")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        
        refreshVolantes()
    }
    
    @objc func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        refreshVolantes()
    }
    
    func refreshVolantes() {
        messageLabel.isHidden = true
        HttpRequest.httpGet("volante",
                            success: { (response) -> Void in
                                self.volantes = try! JSONDecoder().decode([Volante].self, from: Data(response.utf8))
                                
                                print(self.volantes)
                                
                                if self.volantes.count == 0 {
                                    self.messageLabel.text = "¡Sin volantes para mostrar!"
                                    self.messageLabel.isHidden = false
                                    
                                    return
                                }
                                
                                self.tableView.reloadData()
                                
                                self.refreshControl.endRefreshing()
                            }, failure: { (code, response) -> Void in
                                if code == HttpRequest.INCOMPLETE {
                                    self.messageLabel.text = "No se pudo conectar al servidor. Problemas con la red."
                                }
                                
                                self.messageLabel.isHidden = false
                            })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return volantes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let volante = volantes[indexPath.row]
        let cell : VolanteTableCell = tableView.dequeueReusableCell(withIdentifier: "volanteCell") as! VolanteTableCell
        
        cell.title.text = volante.titulo
        
        cell.preview.kf.setImage(with: URL(string: volante.imagenes[0]))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let images = volantes[0].imagenes.map { (string) -> LightboxImage in
            return LightboxImage(imageURL: URL(string: string)!)
        }
        
        let controller = LightboxController(images: images)
        
        controller.dynamicBackground = true
        
        present(controller, animated: true) { () in
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
