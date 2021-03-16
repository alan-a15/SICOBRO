//
//  SICobroViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 12/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit

class SICobroViewController: AbstractUIViewController {
    
    //TO-DO Make these servcices singleton
    let billPocketService:BillPocketService = BillPocketService.getInstance()
    
    let mobileSalesOpsService:MobileSalesOpsService = MobileSalesOpsService.getInstance()
    
    let servicesPaymentService:ServicesPaymentService = ServicesPaymentService.getInstance()
    
    var parentController : HomePageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
