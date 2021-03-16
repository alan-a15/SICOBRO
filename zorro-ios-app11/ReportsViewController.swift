//
//  ReportsViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 13/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit

class ReportsViewController: SICobroViewController {

    @IBOutlet weak var containerView: RounderCornerView!
    
    var sliding:CustomSwipeViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //var swipeController = CustomSwipeViewController()
        sliding = CustomSwipeViewController()
        sliding!.parentController = self
        
        addChild(sliding!)
        sliding!.view.frame = containerView.bounds
        sliding!.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(self.sliding!.view)
        sliding!.didMove(toParent: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Create Tabs
        //let tabController = UITabBarController()
        //tabController.delegate = self
        //let controllers:[AbstractReportViewController] = TabReportSection.getUITabBarItems()
        //tabController.viewControllers = controllers
        
        /*
        TabReportSection.getTabsReports(enabledModules: nil).forEach { (it) in
            self.sliding?.addItem(item: it.reportControlller!, title: it.name)
        }
        self.sliding?.setHeaderActiveColor(color: UIColor(named: "textSectionColor")!)
        self.sliding?.setHeaderInActiveColor(color: UIColor(named: "nonSelectedText")!)
        self.sliding?.setHeaderBackgroundColor(color: UIColor(named: "colorPrimaryDark")!)
        self.sliding?.build()
         */
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

class TabReportSection {
    var name : String = ""
    var reportControlller : AbstractReportViewController?
    var section:FragmentSection?
    var enabled:Bool = false
    
    init(name : String, section:FragmentSection?) {
        self.name = name
        self.section = section
    }
    
    static var TABS_REPORTS : [TabReportSection] = []
    
    static func getTabsReports(enabledModules: EnabledModules?) -> [TabReportSection] {
        if(TABS_REPORTS.isEmpty) {
            TABS_REPORTS.append (
                TabReportSection(
                    name: "RECARGAS",
                    //reportControlller: ReportRecargasViewController(tabName: "Recargas"),
                    section: FragmentSection.RECARGAS)
            )
            TABS_REPORTS.append (
                TabReportSection(
                    name: "COBRO T.",
                    //reportControlller: AbstractReportViewController<Any, Any>(tabName: "Cobros (En progreso)"),
                    section: FragmentSection.COBROS)
            )
            TABS_REPORTS.append (
                TabReportSection(
                    name: "SERVICIOS",
                    //reportControlller: AbstractReportViewController<Any, Any>(tabName: "Pago Servicios (En progreso)"),
                    section: FragmentSection.PAGO_SERVICIOS)
            )
        }
        if (enabledModules != nil) {
            TABS_REPORTS.forEach { $0.setModuleEnablement(enabledModules: enabledModules!) }
        }
        return TABS_REPORTS
    }
    
    /*
     *
     */
    private func setModuleEnablement(enabledModules: EnabledModules) -> TabReportSection {
        switch (section) {
            case .COBROS:         self.enabled = enabledModules.cardPaymentEnabled ?? false; break;
            case .RECARGAS:       self.enabled = enabledModules.taeEnabled ?? false; break;
            case .PAGO_SERVICIOS: self.enabled = enabledModules.paymentServicesEnabled ?? false; break;
            case .REPORTES:       self.enabled = true; break;
            
            case .none:break;
            case .MENU:break;
            case .CONTACT:break;
            case .NONE:break;
        }
        return self
    }
    
    static func getUITabBarItems() -> [SICobroViewController] {
        for (index, item) in TABS_REPORTS.enumerated() {
            let tabBarItem = UITabBarItem(title: item.name, image: nil, tag: index)
            tabBarItem.titlePositionAdjustment = UIOffset(horizontal:0, vertical:-16)
            item.reportControlller?.tabBarItem = tabBarItem
        }
        return TABS_REPORTS.map { (t) -> SICobroViewController in
            t.reportControlller!
        }
    }
}
