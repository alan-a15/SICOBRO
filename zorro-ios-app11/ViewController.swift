//
//  ViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 21/03/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit
import Foundation

extension UIScreen {
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}


extension UIColor {
    static let colorPrimary = UIColor(named: "colorPrimary")
    static let helperColor = UIColor(named: "helperColor")
}



extension CGFloat {
    func getminimum(value2:CGFloat)->CGFloat {
        if self < value2 {
            return self
        } else {
            return value2
        }
    }
}


/// Initial View, Banners View
class ViewController: CenterMenuViewController, UITableViewDataSource, UITableViewDelegate, MenuHandler  {
    
    @IBOutlet weak var bannerTableView: UITableView!
    
    @IBOutlet weak var menuButton: UIImageView!
    
    var banners : [Banner] = [] // = BannerTestData.banners()
    var itemHeight:CGFloat = 0
        
    //@State var showMenu = false
    
    //var centerNavigationController: UINavigationController!
    //var centerViewController: CenterViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.menuHandler = self
        
        
        bannerTableView.dataSource = self
        
        banners = [Banner]()
        let parsedJSON = JsonUtils.readJSONFromFile(fileName: "banners")
        print("parsedJSON: \(String(describing: parsedJSON))")
        guard let jsonBanners = parsedJSON as? [[String: Any]] else {
              itemHeight = 100
              return
        }
        print("jsonBanners: \(jsonBanners)")
        
        for banner in jsonBanners {
            print("banner FOUNDED: \(banner["name"] as? String ?? "")")
            banners.append(Banner(banner))
        }
        print("Banners found: \(banners.count)")
        
        let frameSize:CGFloat = UIScreen.screenHeight
        itemHeight = CGFloat(bannerTableView.frame.height) / CGFloat(banners.count)
        print("Total height of screen: \(UIScreen.screenHeight)")
        print("Height of bannerTableView: \(bannerTableView.frame.height)")
        print("Calculated Height \(itemHeight)")
        
        //var navHeight = (frameSize * 0.10)
        //if let navController = self.navigationController {
        //    navHeight = self.navigationController!.navigationBar.frame.height
        //}
        
        //itemHeight = (frameSize - (frameSize * 0.10) - navHeight) / CGFloat(banners.count)
        //itemHeight = (frameSize - (frameSize * 0.13)) / CGFloat(banners.count)
        itemHeight = (frameSize - (frameSize * getProporcionalValue())) / CGFloat(banners.count)
        print("Calculated Height 2: \(itemHeight)")
        
        bannerTableView.rowHeight = CGFloat(itemHeight)
        bannerTableView.estimatedRowHeight = CGFloat(itemHeight)
        
        bannerTableView.reloadData()
        
        //let tap = UITapGestureRecognizer(target: self, action: #selector(openLeftMenu))
        //menuButton.addGestureRecognizer(tap)
        //menuButton.isUserInteractionEnabled = true
        
        
        /*
        print("===========================")
        print("FONTS!!!!")
        for family: String in UIFont.familyNames
               {
                   print(family)
                   for names: String in UIFont.fontNames(forFamilyName: family)
                   {
                       print("== \(names)")
                   }
               }
        print("===========================")
         */
    }
    
    private func getProporcionalValue() -> CGFloat {
        switch UIScreen.main.nativeBounds.height {
            case 1136:      // print("iPhone 5 or 5S or 5C")
                return 0.13
            
            case 1334:      // .iPhones_6_6s_7_8
                return 0.13
            
            case 1792:
                return 0.13 //return .iPhone_XR_11
            
            case 1920, 2208:
                return 0.13 //.iPhones_6Plus_6sPlus_7Plus_8Plus
            
            /*
            case 2426:
                return .iPhone_11Pro
            case 2436:
                return .iPhones_X_XS
            case 2688:
                return .iPhone_XSMax_ProMax */
            default:
                return 0.18
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return banners.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let banner = banners[indexPath.row]
        print("Banner row \(indexPath.row)")
        print("Banner name \(banner.name)")
        print("Banner imag \(banner.imageSrc)")
        print("Banner target \(banner.target)")
        
        if(banner.target ==  BannerTarget.CARROUSEL) {
            print("On cellForRowAt")
            let cell : CarrouselCellView = self.bannerTableView.dequeueReusableCell(withIdentifier: "customCarrousel")! as! CarrouselCellView
            cell.setItemHeight(height: itemHeight)
            cell.itemWidth = view.frame.width
            cell.setCarrouselBanner(carBanner: banner)
            cell.carrouselCollectionView.frame.size.width = view.frame.width
            cell.carrouselCollectionView.frame.size.height = CGFloat(itemHeight)
            cell.layoutIfNeeded()
            return cell
        } else {
            let cell : BannerViewCellController = self.bannerTableView.dequeueReusableCell(withIdentifier: "bannerView")! as! BannerViewCellController
            cell.imgSrc.image = UIImage(named: banner.imageSrc)
            cell.imgSrc.frame.size.height = CGFloat(itemHeight)
            
            switch banner.target {
                 case .URL:
                    cell.imgSrc.tag = indexPath.row
                    //let tap = UITapGestureRecognizer(target: self, action: #selector(openURL))
                    //let tap = UITapGestureRecognizer(target: self, action: #selector(openUrlPopUp))
                    let tap = UITapGestureRecognizer(target: self, action: #selector(openUrlController))
                    
                    cell.imgSrc.addGestureRecognizer(tap)
                    cell.imgSrc.isUserInteractionEnabled = true
                    break;
                
                case .SICOBRO:
                    let tap = UITapGestureRecognizer(target: self, action: #selector(goSiCobro))
                    cell.imgSrc.addGestureRecognizer(tap)
                    cell.imgSrc.isUserInteractionEnabled = true
                    break;
                
                case .CARROUSEL:
                    break;
                    
                case .COMINUDADRED:
                    let tap = UITapGestureRecognizer(target: self, action: #selector(goComunidadRed))
                    cell.imgSrc.addGestureRecognizer(tap)
                    cell.imgSrc.isUserInteractionEnabled = true
                    break;
                    
                case .FINDSTORE:
                    let tap = UITapGestureRecognizer(target: self, action: #selector(goFindStore))
                    cell.imgSrc.addGestureRecognizer(tap)
                    cell.imgSrc.isUserInteractionEnabled = true
                    break;
                    
                case .VOLANTES:
                    let tap = UITapGestureRecognizer(target: self, action: #selector(goVolante))
                    cell.imgSrc.addGestureRecognizer(tap)
                    cell.imgSrc.isUserInteractionEnabled = true
                    break;
                    
                case .AD:
                    break;
            }
        //https://stackoverflow.com/questions/25971147/uitableview-dynamic-cell-heights-only-correct-after-some-scrolling
            cell.layoutIfNeeded()
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(itemHeight)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(itemHeight)
    }
    
    func getMenuType() -> MenuItemSection {
        return MenuItemSection.BANNERS
    }
    
    /*
     *
     */
    @objc func openURL(sender: UITapGestureRecognizer) {
        print("SENDER \(sender)")
        let banner : Banner = banners[sender.view!.tag]
        print("banner \(banner)")
        print("URL  \(banner.targetUrl)")
        if let url = URL(string: banner.targetUrl ?? "") {
            UIApplication.shared.open(url)
        }
    }
    
    /*
     *
     */
    @objc func openUrlPopUp(sender: UITapGestureRecognizer) {
        print("SENDER \(sender)")
        let banner : Banner = banners[sender.view!.tag]
        print("banner \(banner)")
        print("URL  \(banner.targetUrl)")
        
        let storyboard = UIStoryboard(name: "CustomPopup" , bundle: nil)
        // Forcing to unwrap the ViewController
        let popup = storyboard.instantiateInitialViewController() as! CustomPopUpViewController
        popup.customTitle = banner.name
        popup.setWebUrl(surl: banner.targetUrl)
        popup.fixedHeightSizePer = 0.85
        popup.webDomain = "www.zorroabarrotero.com.mx"
        
        self.present(popup, animated: true)
    }
    
    @objc func openUrlController(sender: UITapGestureRecognizer) {
        print("SENDER \(sender)")
        let banner : Banner = banners[sender.view!.tag]
        print("banner \(banner)")
        print("URL  \(banner.targetUrl)")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewControllerToInsert = storyboard.instantiateViewController(
            withIdentifier: "zorroUrls") as! UrlsViewController
        
        viewControllerToInsert.titlePage = banner.name
        viewControllerToInsert.webUrlPage = banner.targetUrl
        viewControllerToInsert.webDomain = "www.zorroabarrotero.com.mx"
        
        // create an object using the current navigation stack
        var navStackArray: [UIViewController]! = self.navigationController?.viewControllers
        navStackArray.append(viewControllerToInsert)
        self.navigationController?.setViewControllers(navStackArray, animated: true)
    }
    
    
    
    /*
     *
     */
    @objc func goSiCobro() {
        /* Validate Sessions method */
        validateSessions()
    }
    
    @objc func goComunidadRed() {
        performTransitionWithIdentifier(identifier: TransitionsViews.redLoginController.rawValue, destroyCurrentView: false)
    }
    
    @objc func goVolante() {
        performTransitionWithIdentifier(identifier: TransitionsViews.volanteViewController.rawValue, destroyCurrentView: false)
    }
    
    @objc func goFindStore() {
        performTransitionWithIdentifier(identifier: TransitionsViews.findStoreViewController.rawValue, destroyCurrentView: false)
    }
    
    /*
    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        
        if (identifier == "setPinTransCustom") {
            // initialize the view controller you want to insert
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewControllerToInsert = storyboard.instantiateViewController(
                withIdentifier: "setPin") as! SetPinViewController

            // set any passed properties
            //viewControllerToInsert.passedProperty = propertyToPass

            // create an object using the current navigation stack
            var navStackArray: [UIViewController]! = self.navigationController?.viewControllers
            
            navStackArray.append(viewControllerToInsert)

            self.navigationController?.setViewControllers(navStackArray, animated: true)
        } else if (identifier == "SiCobroViewController") {
            goToSiCobroHomePage()
        } else {
            super.performSegue(withIdentifier: identifier, sender: sender)
        }
    }
     */
    
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if(segue.identifier == "pinLoginTrans") {
            let view : PinLoginViewController = segue.destination as! PinLoginViewController
            view.isTimedOut = !self.isActiveSession
        }
    }
     */
}

// Helper Class for BannerView cell
class BannerViewCellController : UITableViewCell {
    @IBOutlet weak var imgSrc: UIImageView!
}
    
