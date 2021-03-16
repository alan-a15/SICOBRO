//
//  PaymentServicesHomeViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 19/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit
import Alamofire

class PaymentServicesHomeViewController: SICobroViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var segmentsTable: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    private var srvSegmentList:[ServiceSegment]?
    
    var itemHeight:CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        indicator.isHidden = false
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        
        segmentsTable.backgroundColor = UIColor(named: "colorPrimaryDark")
        segmentsTable.separatorStyle = .none
        segmentsTable.tableFooterView = UIView()
        segmentsTable.dataSource = self
        segmentsTable.delegate = self
        segmentsTable.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Retrieving Segments")
        servicesPaymentService.getSegments( callback: getSegmentsCallback() )
    }
    
    func getSegmentsCallback() -> RestCallback<[Segment]> {
        let onResponse : (([Segment]?) -> ())? = { response in
            self.indicator.stopAnimating()
            print("response \(String(describing: response))")
            self.srvSegmentList = ServiceSegment.loadFromLstSegments(segments: response!)
            
            let frameSize:CGFloat = self.view.frame.height
            self.itemHeight = CGFloat(self.segmentsTable.frame.height) / CGFloat(self.srvSegmentList!.count)
            print("[ContactUsViewController] Total height of screen: \(frameSize)")
            print("[ContactUsViewController] Height of contactList: \(self.segmentsTable.frame.height)")
            print("[ContactUsViewController] Calculated Height \(self.itemHeight)")
            //self.itemHeight = 100.0 //self.view.frame.height / CGFloat(self.srvSegmentList!.count)
            self.segmentsTable.rowHeight = CGFloat(self.itemHeight)
            self.segmentsTable.estimatedRowHeight = CGFloat(self.itemHeight)
            
            self.segmentsTable.reloadData()
        }
        
        let apiError : ((ApiError)->())? =  { apiError in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            let smsg = "Error Obteniendo Segmentos"
            guard let msg = apiError.message else {
                self.showAlert(message: smsg)
                return
            }
            self.showAlert(message: "\(smsg): \(msg)")
        }
        
        let onFailure : ((AFError?,HTTPURLResponse?)->())? = { (error, response) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            print("error \(String(describing: error))")
            print("errorDescription \(String(describing: error?.errorDescription))")
            print("failedStringEncoding \(String(describing: error?.failedStringEncoding))")
            print("destinationURL \(String(describing: error?.destinationURL))")
            
            print("response \(String(describing: response))")
            print("statusCode \(String(describing: response?.statusCode))")
            self.showAlert(message: "Ocurrio un error al obtener Segmentos disponibles. Verifique su conexión a internet. - \(String(describing: error?.errorDescription))")
        }
        return RestCallback<[Segment]>(onResponse: onResponse, onApiError: apiError, onFailure: onFailure)
    }
    
    
    func goToSubmitForm(item:ServiceSegment) {
        if(parentController != nil) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let target = storyboard.instantiateViewController(withIdentifier: "formServicePaymentVC") as! PaymentServicesFormViewController
            target.srvSegmentType = item
            parentController?.onSectionChange(target: target, fragmentSection: FragmentSection.PAGO_SERVICIOS)
        }
    }
    
    /*
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return UITableView.automaticDimension
    }
     */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let srvSegmentList = srvSegmentList else {
            return 0
        }
        return srvSegmentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("item row \(indexPath.row)")
        let cell : SegmenTabletCellView = self.segmentsTable.dequeueReusableCell(withIdentifier: "segmentCell") as! SegmenTabletCellView
        cell.backgroundColor = UIColor(named: "colorPrimaryDark")
        cell.container.layer.borderWidth = 2
        cell.container.layer.borderColor = UIColor(named: "colorPrimary")?.cgColor
        if let srvSegmentList = srvSegmentList {
            let item:ServiceSegment = srvSegmentList[indexPath.row]
            cell.segName.text = item.name
            cell.segName.font = UIFont(name: "Roboto-Regular", size: self.itemHeight / 3.5)
            cell.segName.numberOfLines = 0
            cell.segName.adjustsFontSizeToFitWidth = true
            cell.segName.minimumScaleFactor = 0.5
            cell.segSamples.text = item.samples
            cell.segSamples.font = UIFont(name: "DomDiagonalBT-Regular", size: self.itemHeight / 5.0)
            cell.segSamples.numberOfLines = 0
            cell.segSamples.adjustsFontSizeToFitWidth = true
            cell.segSamples.minimumScaleFactor = 0.5
            cell.segIcon.image = UIImage(named: item.icon)
            
            //let tap = UITapGestureRecognizer(target: self, action: #selector(goToSubmitForm))
            //cell.addGestureRecognizer(tap)
            
            cell.layoutIfNeeded()
        }
        cell.selectionStyle = .default
        let view = UIView()
        view.backgroundColor = UIColor(named: "drawer_background2")
        cell.selectedBackgroundView = view
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("item row selected \(indexPath.row)")
        if let srvSegmentList = srvSegmentList {
            let item:ServiceSegment = srvSegmentList[indexPath.row]
            goToSubmitForm(item: item)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(itemHeight)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(itemHeight)
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

class SegmenTabletCellView  : UITableViewCell {
    
    @IBOutlet weak var segName: UILabel!
    @IBOutlet weak var segSamples: UILabel!
    @IBOutlet weak var segIcon: UIImageView!
    @IBOutlet weak var container: RounderCornerView!
    
}
