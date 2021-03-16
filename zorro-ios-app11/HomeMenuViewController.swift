//
//  HomeMenuViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 09/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit
import Alamofire

extension UIImage {

    var noir: UIImage {
        let context = CIContext(options: nil)
        let currentFilter = CIFilter(name: "CIPhotoEffectNoir")!
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        let output = currentFilter.outputImage!
        let cgImage = context.createCGImage(output, from: output.extent)!
        let processedImage = UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)

        return processedImage
    }
}

class HomeMenuViewController: SICobroViewController,
                              UICollectionViewDataSource,
                              UICollectionViewDelegate,
                              UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var greetingMsg: UILabel!
    
    @IBOutlet weak var menuCollection: UICollectionView!
    
    var menuSections:[SectionSiCobro] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        menuCollection.dataSource = self
        menuCollection.delegate = self
        
        menuSections = SectionSiCobro.getSections(enabledModules: nil)
        print("menuSections count: \(menuSections.count)")
        
        menuCollection.reloadData()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        parentController?.refreshHeader(fragmentSection: FragmentSection.MENU)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Retrieving modules")
        mobileSalesOpsService.getModulesInfo(callback: getEnablementModulesCallback())
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let index = (indexPath.section * 2) + (indexPath.row)
        
        let section : SectionSiCobro = menuSections[index]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "menuItemCell", for: indexPath) as! MenuItemViewCell
        cell.itemDisplay.text = section.name
        let sectionImg = UIImage(named: section.srcImage)
        
        if(!section.enabled) {
            print("Disabling section")
            cell.itemImg.image = sectionImg?.noir
        } else {
            cell.itemImg.image = sectionImg
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let index = (indexPath.section * 2) + (indexPath.row)
        let section : SectionSiCobro = menuSections[index]
        print("Item selected: \(section.framentSection) N[\(index)]")
        
        if(!section.enabled) {
            print("This [\(section.name)] section is disabled")
            return
        }
        
        let targetIdentifier:String? = section.getControllerIdentifier()
        guard targetIdentifier != nil && !(targetIdentifier?.starts(with: "WIP") ?? true) else {
            self.showAlert(message: "Sección \(section.name) en construcción.")
            return
        }
        print("Item targetIdentifier: \(String(describing: targetIdentifier))")
        
        if(parentController != nil) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let target = storyboard.instantiateViewController(withIdentifier: targetIdentifier!) as! SICobroViewController
            parentController?.onSectionChange(target: target, fragmentSection: section.framentSection)
            parentController?.refreshHeader(fragmentSection: section.framentSection)
            //parentController?.refreshFloatingMenu(section: section.framentSection)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat(view.frame.size.width / 2.5),
                      height:CGFloat(view.frame.size.height / 3.0))
    }
    
    private func getEnablementModulesCallback() -> RestCallback<EnabledModules> {
        let enableModulesOnResponse : ((EnabledModules?) -> ())? = { response in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            print("response \(String(describing: response))")
            
            var enabledModules:EnabledModules? = response
            if( enabledModules == nil ) {
                enabledModules = EnabledModules()
                enabledModules?.cardPaymentEnabled = false
                enabledModules?.paymentServicesEnabled = false
                enabledModules?.taeEnabled = false
            }
            self.menuSections = SectionSiCobro.getSections(enabledModules: enabledModules)
            self.menuCollection.reloadData()
        }
        
        let enableModulesApiError : ((ApiError)->())? =  { apiError in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            let smsg = "Error Obteniendo modulos disponibles."
            guard let msg = apiError.message else {
                self.showAlert(message: smsg)
                return
            }
            self.showAlert(message: "\(smsg): \(msg)")
        }
        
        let enableModulesFailure : ((AFError?,HTTPURLResponse?)->())? = { (error, response) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            print("error \(String(describing: error))")
            print("errorDescription \(String(describing: error?.errorDescription))")
            print("failedStringEncoding \(String(describing: error?.failedStringEncoding))")
            print("destinationURL \(String(describing: error?.destinationURL))")
            
            print("response \(String(describing: response))")
            print("statusCode \(String(describing: response?.statusCode))")
            self.showAlert(message: "Ocurrio un error al obtener modulos disponibles. Verifique su conexión a internet. - \(String(describing: error?.errorDescription))")
        }
        return RestCallback<EnabledModules>(onResponse: enableModulesOnResponse, onApiError: enableModulesApiError, onFailure: enableModulesFailure)
    }
}

class MenuItemViewCell : UICollectionViewCell {
    
    @IBOutlet weak var itemImg: UIImageView!
    @IBOutlet weak var itemDisplay: UILabel!
}
