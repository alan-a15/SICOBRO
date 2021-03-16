//
//  UrlsViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 11/07/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit
import Kingfisher
import Lightbox

class ComunicadoDetailViewController: ZorroAbstracUIViewController {
    
    var comunicado: Comunicado = Comunicado()
    
    @IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var menuButton: UIImageView!
    
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var errorMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBackButton(backButton)
        addBottomNavigationDrawer(menuButton)
        
        HttpRequest.httpGet("comunicado/campana/\(campanaId)/\(noRed)",
                            success: { (response) -> Void in
                                self.comunicado = try! JSONDecoder().decode(Comunicado.self, from: Data(response.utf8))
                                
                                print(self.comunicado)
                                
                                self.header.text = self.comunicado.titulo
                                self.content.text = self.comunicado.mensaje
                                
                                if let imagen = self.comunicado.imagen {
                                    self.image.kf.setImage(with: URL(string: "http://170.245.189.244/kioscoapi/\(imagen)"))
                                }
                                
                                let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.showModalImage))
                                self.image.addGestureRecognizer(tap1)
                                self.image.isUserInteractionEnabled = true
                            }, failure: { (code, response) -> Void in
                                self.header.isHidden = true
                                self.image.isHidden = true
                                self.content.isHidden = true
                                self.errorMessage.isHidden = false
                            })
    }
    
    @objc func showModalImage() {
        if let imagen = self.comunicado.imagen {
            let image = [LightboxImage(imageURL: URL(string: "http://170.245.189.244/kioscoapi/\(imagen)")!)]
            
            let controller = LightboxController(images: image)
            
            controller.dynamicBackground = true
            
            present(controller, animated: true, completion: nil)
        }
    }
}
