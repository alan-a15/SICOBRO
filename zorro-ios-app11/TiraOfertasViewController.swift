//
//  UrlsViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 11/07/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialNavigationDrawer
import MaterialComponents.MaterialSnackbar

enum TipoTira: Int {
    case Default = 1
    case Adicional = 2
}

enum LoadingState: Int {
    case LoadAll = 1
    case LoadSucursales = 2
    case ShowAll = 3
    case ShowReload = 4
}

class TiraOfertasCell: UITableViewCell {
    @IBOutlet weak var articulo: UILabel!
    @IBOutlet weak var descuento: UILabel!
    @IBOutlet weak var vigencia: UILabel!
}

class TiraOfertasViewController: ZorroAbstracUIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private var tiraOfertas: TiraOfertas = TiraOfertas()
    private var tipoTira: TipoTira = .Default
    
    private let token: String
    
    private var sucursales: [Sucursal] = []
    private var sucursal: String = ""
    
    @IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var menuButton: UIImageView!
    
    @IBOutlet weak var tiraView: UIView!
    
    @IBOutlet weak var tvCliente: UILabel!
    @IBOutlet weak var tvNumCliente: UILabel!
    @IBOutlet weak var tvSucursal: UILabel!
    @IBOutlet weak var tvFecha: UILabel!
    @IBOutlet weak var tvMensaje: UILabel!
    @IBOutlet weak var tvMensaje1: UILabel!
    @IBOutlet weak var tvMensaje2: UILabel!
    @IBOutlet weak var tvErrorMessage: UITextView!
    
    @IBOutlet weak var barcodeImage: UIImageView!
    @IBOutlet weak var barcodeNum: UILabel!
    
    @IBOutlet weak var btnTiraAdicional: CustomRoundedButton!
    @IBOutlet weak var btnTiraDefault: CustomRoundedButton!
    @IBOutlet weak var btnRecargar: CustomRoundedButton!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    
    @IBOutlet weak var sucursalView: UIView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var pickerSucursal: UIPickerView!
    
    required init?(coder: NSCoder) {
        let firebaseDefaults = UserDefaults.init(suiteName: RedDefaults.firebase.rawValue)!
        token = firebaseDefaults.string(forKey: "FCMToken") ?? ""
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBackButton(backButton)
        addBottomNavigationDrawer(menuButton)
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissPicker))
        toolbar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        tvMensaje.isHidden = true
        
        refreshTira()
    }
    
    @objc func refresh() {
        refreshTira()
    }
    
    func showSnackBar(_ message: String) {
        let message = MDCSnackbarMessage(text: message)
        message.duration = 3
        MDCSnackbarManager.default.show(message)
    }
    
    func showTira(loaded: Bool) {
        tvCliente.text = tiraOfertas.nombreSocio
        tvNumCliente.text = tiraOfertas.numeroCliente
        tvSucursal.text = tiraOfertas.sucursal.nombre
        tvFecha.text = tiraOfertas.fechaImpresion
        tvMensaje1.text = tiraOfertas.notaPieTira01
        tvMensaje2.text = tiraOfertas.notaPieTira02
        
        barcodeImage.image = UIImage(barcode: tiraOfertas.numeroClienteFrecuente, size: CGSize(width: 300, height: 200))
        barcodeNum.text = tiraOfertas.numeroClienteFrecuente
        
        tableView.reloadData()
        tableView.sizeToFit()
        
        if loaded {
            try! writeTira()
        }
        
        loading(.ShowAll)
    }
    
    func writeTira() throws {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent("TiraOfertas\(tipoTira.rawValue).data")
            let data = try JSONEncoder().encode(tiraOfertas)
            let text = String(data: data, encoding: .utf8)
            
            try text!.write(to: fileURL, atomically: false, encoding: .utf8)
        }
    }
    
    func readTira() throws {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent("TiraOfertas\(tipoTira.rawValue).data")
            
            let text = try String(contentsOf: fileURL, encoding: .utf8)
            tiraOfertas = try JSONDecoder().decode(TiraOfertas.self, from: Data(text.utf8))
        }
    }
    
    func loading(_ state: LoadingState) {
        switch state {
        case .LoadAll:
            spinner.startAnimating()
            tiraView.isHidden = true
        case .LoadSucursales:
            spinner.startAnimating()
            tiraView.isHidden = false
        case .ShowAll:
            spinner.stopAnimating()
            tiraView.isHidden = false
        case .ShowReload:
            spinner.stopAnimating()
            tiraView.isHidden = true
        }
        
        let showReload = state == .ShowReload
        btnRecargar.isHidden = !showReload
        tvErrorMessage.isHidden = !showReload
        
        if state == .LoadAll || state == .LoadSucursales {
            view.isUserInteractionEnabled = false
        } else {
            view.isUserInteractionEnabled = true
        }
        
        let tiraDefault = tipoTira == .Default
        
        btnTiraDefault.isHidden = tiraDefault
        btnTiraAdicional.isHidden = !tiraDefault
    }
    
    func refreshTira(_ sucursal: String = "") {
        loading(.LoadAll)
        
        HttpRequest.httpPost("tiraofertas/\(noRed)/\(sucursal)",
                             body: token,
                             success: { (response) -> Void in
                                self.tiraOfertas = try! JSONDecoder().decode(TiraOfertas.self, from: Data(response.utf8))
                                
                                self.defaults.setValue(Date.init(), forKey: "TiraDate_\(self.tipoTira.rawValue)")
                                
                                self.showTira(loaded: true)
                             }, failure: { (code, response) -> Void in
                                self.showSnackBar("No se pudo recargar la tira. Problemas con la red.")
                                
                                do {
                                    try self.readTira()
                                    self.showTira(loaded: false)
                                } catch {
                                    self.loading(.ShowReload)
                                }
                             })
    }
    
    func loadSucursales() {
        loading(.LoadSucursales)
        
        HttpRequest.httpGet("sucursal/\(noRed)",
                             success: {
                                self.sucursales = try! JSONDecoder().decode([Sucursal].self, from: Data($0.utf8))
                                
                                if (self.sucursales.count == 1) {
                                    let suc = self.sucursales[0]
                                    
                                    print("Obtained: \(suc)")
                                    
                                    self.defaults.setValue(suc.sucursal, forKey: "currentSucursal")
                                    self.refreshTira(suc.sucursal)
                                    
                                    return
                                }
                                
                                self.pickerSucursal.reloadAllComponents()
                                
                                self.sucursalView.isHidden = false
                             }, failure: { (code, response) -> Void in
                                self.showSnackBar("No se pudo cargar el listado de sucursales. Problemas con la red.")
                             }, always: { self.loading(.ShowAll) })
    }
    
    @IBAction func tiraDefaultPressed(_ sender: Any) {
        print("Default")
        
        tipoTira = .Default
        let dateKey = "TiraDate_\(tipoTira.rawValue)"
        
        guard let date = defaults.value(forKey: dateKey) as? Date else {
            refreshTira()
            
            return
        }
        
        guard Calendar.current.dateComponents([.hour], from: date, to: Date.init()).hour! >= 2 else {
            do {
                try readTira()
                showTira(loaded: false)
            } catch {
                loading(.ShowReload)
            }
            
            return
        }
        
        refreshTira()
    }
    
    @IBAction func tiraAdicionalPressed(_ sender: Any) {
        print("Adicional")
        
        tipoTira = .Adicional
        let dateKey = "TiraDate_\(tipoTira.rawValue)"
        
        let sucursal = defaults.value(forKey: "currentSucursal") as? String
        
        guard let date = defaults.value(forKey: dateKey) as? Date else {
            loading(.LoadSucursales)
            
            if let suc = sucursal {
                refreshTira(suc)
            } else {
                loadSucursales()
            }
            
            return
        }
        
        guard Calendar.current.dateComponents([.hour], from: date, to: Date.init()).hour! >= 2 else {
            do {
                try readTira()
                showTira(loaded: false)
            } catch {
                loading(.ShowReload)
            }
            
            return
        }
        
        guard Calendar.current.dateComponents([.day], from: date, to: Date.init()).day! == 0 else {
            loading(.LoadSucursales)
            loadSucursales()
            
            return
        }
        
        refreshTira(sucursal!)
    }
    
    @IBAction func recargarPressed(_ sender: Any) {
        refreshTira()
    }
    
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
        self.tableHeight!.constant = self.tableView.contentSize.height
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tiraOfertas.promociones.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tiraOfertas.promociones[section].ofertas.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tiraOfertas.promociones[section].nombre
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let oferta = tiraOfertas.promociones[indexPath.section].ofertas[indexPath.row]
        let cell : TiraOfertasCell = tableView.dequeueReusableCell(withIdentifier: "ofertaCell") as! TiraOfertasCell
        
        cell.articulo.text = oferta.articulo
        cell.descuento.text = oferta.descuento
        cell.vigencia.text = oferta.vigencia ?? ""
        
        return cell
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sucursales.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sucursales[row].nombre
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        sucursal = sucursales[row].sucursal
        print("Selected: \(sucursal)")
    }
    
    @objc func dismissPicker() {
        sucursalView.isHidden = true
    }
    
    @objc func doneClick() {
        sucursalView.isHidden = true
        
        defaults.setValue(sucursal, forKey: "currentSucursal")
        print("Done selecting: \(sucursal)")
        refreshTira(sucursal)
    }
}
