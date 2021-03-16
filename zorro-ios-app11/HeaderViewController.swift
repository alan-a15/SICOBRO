//
//  HeaderViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 08/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit
import IPImage
import Alamofire
import InitialsImageView

class HeaderViewController: SICobroViewController {

    @IBOutlet weak var greeting: UILabel!
    
    @IBOutlet weak var storeName: UILabel!
    
    @IBOutlet weak var redId: UILabel!
    
    @IBOutlet weak var avatarView: UIView!
    
    @IBOutlet weak var currentDate: UILabel!
    
    @IBOutlet weak var avatarImgSource: UIImageView!
    
    @IBOutlet weak var bagBalanceLabel: UILabel!
    
    private var avatarImage:IPImage?
    
    private let GENERIC = "Generic User"
    
    private var fragmentSection : FragmentSection? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("In HeaderViewController viewDidLoad")
        
        // Basic user information
        //userSession?.storeName = "El Santo"
        storeName.text = userSession?.storeName
        redId.text = userSession?.redId
        
        // Bottom date
        currentDate.text = Utils.getParsedDateForHeader(date: Date())
        
        print("Generating avstar image")
        avatarImage = IPImage(text: "Neil Patrick Harris", radius: 30,
                              font: UIFont(name: "Cochin-Italic", size: 30),
                              textColor: .black,
                              backgroundColor: UIColor(named: "colorPrimary"))
        //print("Avatar image: \(avatarImage)")
        //avatarImgSource.image = avatarImage!.generateImage()
        
        let user:String = userSession!.storeName ?? GENERIC
        
        let fontSize = avatarImgSource.bounds.width * 0.4
        let customFont:UIFont = .systemFont(ofSize: fontSize)
        
        let attributes: [NSAttributedString.Key: AnyObject] =  [
            NSAttributedString.Key.font: customFont,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        
        avatarImgSource.setImageForName(user,
                                        backgroundColor: UIColor(named: "colorPrimary"),
                                        circular: true,
                                        textAttributes: attributes)
        
        bagBalanceLabel.minimumScaleFactor = 0.35
        bagBalanceLabel.isHidden = false
        bagBalanceLabel.alpha = 0.0
    }
    
    func refreshHeaderData(psection : FragmentSection) {
        fragmentSection = psection
        updateHeaderTypeView()
    }
    
    private func updateHeaderTypeView() {
        debugPrint("HeaderVC -> Section: \(fragmentSection ?? FragmentSection.NONE)")
        
        
        /*
        when(headerType) {
            Companion.HeaderType.HOME ->  {
                /*headerLayout.background = context!!.getDrawable(R.drawable.header_degraded_banner)*/
                headerRightSide.visibility = View.INVISIBLE
                headerRightSideLogOut.visibility = View.GONE
                /*greetting.setTextColor(context!!.getColor(R.color.textSectionColor))*/
                /*headerDate.setTextColor(context!!.getColor(R.color.textSectionColor))*/
            }
        */
         
        /*
            Companion.HeaderType.SICOBRO ->  {
         */
        setTxtBalanaceBagValue(label: "Cargando..")
        bagBalanceLabel.isHidden = false
        //bagBalanceLabel.alpha = 0.0
        if(fragmentSection != nil) {
            switch(fragmentSection) {
            
                case .PAGO_SERVICIOS, .RECARGAS:
                    // Shows balance only if section is RECARGAS/PAGO_SERVICIOS
                    //bagBalanceLabel.isHidden = false
                    UIView.transition(with: self.bagBalanceLabel, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                        self.bagBalanceLabel.alpha = 1.0
                    }, completion: nil)
                    

                    // Update balance (Async)
                    mobileSalesOpsService.getStoreBalance(callback: getBalanceCallback())
                    break;
                
            
                default:
                    //bagBalanceLabel.isHidden = true
                    UIView.transition(with: self.bagBalanceLabel, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                        self.bagBalanceLabel.alpha = 0.0
                    }, completion: nil)
                    break;
            }
        }
    }
    
    private func getBalanceCallback() -> RestCallback<[CustomerBalanceDto]> {
        let onResponse : (([CustomerBalanceDto]?) -> ())? = { response in
            debugPrint("response  \(String(describing: response))")
            if let storeBalances = response {
                var balance: CustomerBalanceDto?
                if(!storeBalances.isEmpty) {
                    switch(self.fragmentSection) {
                        case .PAGO_SERVICIOS:
                            balance = storeBalances.first(where: { (it) -> Bool in
                                it.productType == CustomerBalanceDto.ProductType.servicePayment
                            })
                            break;
                        
                        case .RECARGAS:
                            balance = storeBalances.first(where: { (it) -> Bool in
                                it.productType == CustomerBalanceDto.ProductType.tae
                            })
                            break;
                        
                        default:
                            break;
                    }
                    
                    if let rbalance = balance {
                        self.setTxtBalanaceBagValue(label: rbalance.balanceLabel ?? "$0.00")
                        return
                    }
                }
            }
            self.showAlert(message: "Advertencia: Balance vacio [\(String(describing: self.fragmentSection))]")
        }
        
        let apiError : ((ApiError)->())? =  { apiError in
            let smsg = "Ocurrio un error obteniendo Balances - Message "
            debugPrint("\(smsg): \(apiError.message ?? "-")")
            //self.showAlert(message: "\(smsg): \(msg)")
        }
        
        let onFailure : ((AFError?,HTTPURLResponse?)->())? = { (error, response) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            print("error \(String(describing: error))")
            print("errorDescription \(String(describing: error?.errorDescription))")
            print("failedStringEncoding \(String(describing: error?.failedStringEncoding))")
            print("destinationURL \(String(describing: error?.destinationURL))")
            
            print("response \(String(describing: response))")
            print("statusCode \(String(describing: response?.statusCode))")
            
            debugPrint("Ocurrio un error invocando el servicio: \(String(describing: response)) -  \(String(describing: response?.statusCode))")
            //self.showAlert(message: "Ocurrio un error invocando el servicio. Verifique su conexión a internet.")
        }
        return RestCallback<[CustomerBalanceDto]>(onResponse: onResponse, onApiError: apiError, onFailure: onFailure)
    }
    
    private func setTxtBalanaceBagValue(label : String) {
        bagBalanceLabel.text = "Saldo: \(label)"
        
        // Uncomment only for testing
        //bagBalanceLabel.text = "Saldo: $100,000,000.00"
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
