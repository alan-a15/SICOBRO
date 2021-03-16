//
//  UrlsViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 11/07/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit
import Kingfisher

class ComunicadoTableCell: UITableViewCell {
    var id: Int = 0
    @IBOutlet weak var preview: UIImageView!
    @IBOutlet weak var titulo: UILabel!
    @IBOutlet weak var notificacion: UILabel!
}

class ComunicadoViewController: ZorroAbstracUIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var comunicados = [ComunicadoItem]()
    
    private let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var menuButton: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBackButton(backButton)
        addBottomNavigationDrawer(menuButton)
        
        refreshControl.attributedTitle = NSAttributedString(string: "Desliza hacia abajo para actualizar")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshComunicados()
    }
    
    @objc func refresh(_ sender: AnyObject) {
        refreshComunicados()
    }
    
    func showError(error: String?) {
        if error != nil {
            errorMessage.isHidden = false
            errorMessage.text = error
        } else {
            errorMessage.isHidden = true
        }
    }
    
    func refreshComunicados() {
        HttpRequest.httpGet("comunicado/\(noRed)",
                            success: { (response) -> Void in
                                self.comunicados = try! JSONDecoder().decode([ComunicadoItem].self, from: Data(response.utf8))
                                
                                print(self.comunicados)
                                
                                let notifications = self.comunicados.filter { !$0.visto
                                }.count
                                
                                NotificationsManager.setNotificationsTo(notifications)
                                
                                if self.comunicados.count  == 0 {
                                    self.showError(error: "¡Sin comunicados para mostrar!")
                                    
                                    return
                                }
                                
                                self.showError(error: nil)
                                
                                self.tableView.reloadData()
                                
                                self.refreshControl.endRefreshing()
                            }, failure: { (code, response) -> Void in
                                self.showError(error: "No se pudo cargar el listado de comunicados.\nProblemas con la red.")
                            })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comunicados.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comunicado = comunicados[indexPath.row]
        let cell : ComunicadoTableCell = tableView.dequeueReusableCell(withIdentifier: "comunicadoCell") as! ComunicadoTableCell
        
        cell.id = comunicado.id
        cell.titulo.text = comunicado.titulo
        cell.notificacion.text = comunicado.notificacion
        
        if let imagen = comunicado.imagen {
            cell.preview.kf.setImage(with: URL(string: "http://170.245.189.244/kioscoapi/\(imagen)"))
        }
        
        if !comunicado.visto {
            cell.backgroundColor = UIColor(named: "redComunNotReaded") 
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        campanaId = comunicados[indexPath.row].idCampana
        performTransitionWithIdentifier(identifier: TransitionsViews.comunicadoDetailController.rawValue, destroyCurrentView: false)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
