//
//  SectionSicobro.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 09/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Foundation
import Floaty

enum FragmentSection : String {
    case MENU = "menuVC"
    case CONTACT
    case COBROS = "bpckPaymentsVC"
    case RECARGAS = "taeSalesVC"
    case PAGO_SERVICIOS = "servicePaymentVC"
    case REPORTES = "reportsVC"
    case NONE
}

class SectionSiCobro {
    
    var name : String = ""
    var srcImage : String = ""
    var framentSection : FragmentSection
    var enabled:Bool = false
    var fabItem:FloatyItem
    
    init(name : String, srcImage : String, framentSection : FragmentSection, fabItem:FloatyItem) {
        self.name = name
        self.srcImage = srcImage
        self.framentSection = framentSection
        self.fabItem = fabItem
    }
    
    static var LST_SECTION : [SectionSiCobro] = []

    static func getSections(enabledModules: EnabledModules?) -> [SectionSiCobro] {
        if(LST_SECTION.isEmpty) {
            LST_SECTION.append (
                SectionSiCobro(
                    name: "Cobro con Tarjeta",
                    srcImage: "cobro",
                    framentSection: FragmentSection.COBROS,
                    fabItem: createFloatMenuItem(title: "Cobro con Tarjeta", sicon: "cobro_menu"))
            )
            
            LST_SECTION.append (
                SectionSiCobro(
                    name: "Recargas",
                    srcImage: "recargas",
                    framentSection: FragmentSection.RECARGAS,
                    fabItem: createFloatMenuItem(title: "Recargas", sicon:"recargas_menu"))
            )
            
            LST_SECTION.append (
                SectionSiCobro(
                    name: "Reportes",
                    srcImage: "reportes",
                    framentSection: FragmentSection.REPORTES,
                    fabItem: createFloatMenuItem(title: "Reportes", sicon: "reportes_menu"))
            )
            
            LST_SECTION.append (
                SectionSiCobro(
                    name: "Pago de Servicios",
                    srcImage: "servicios",
                    framentSection: FragmentSection.PAGO_SERVICIOS,
                    fabItem: createFloatMenuItem(title: "Pago de Servicios", sicon: "servicios_menu"))
            )
        }
        if (enabledModules != nil) {
            LST_SECTION.forEach { $0.setModuleEnablement(enabledModules: enabledModules!) }
        }
        return LST_SECTION
        
    }
    
    
    private static func createFloatMenuItem(title: String, sicon: String) -> FloatyItem {
        // Ensure Font before create the items
        if let scustomFont = UIFont(name: "DomDiagonalBT-Regular", size: 25.0) {
            debugPrint("Founded DomDiagonalBT-Regular")
            Floaty.global.font = scustomFont// UIFontMetrics.default.scaledFont(for: scustomFont)
        }
        let item = FloatyItem()
        item.buttonColor = UIColor(named: "colorPrimary")!
        item.icon = UIImage(named: sicon)
        item.title = title
        return item
        
        /**
        return SpeedDialActionItem.Builder(id, context.getDrawable(iconDrawable))
            .setFabBackgroundColor(context.resources.getColor(R.color.colorPrimary))
            .setLabel(context.getString(label))
            .setTheme(R.style.HomeSiCobroTheme_FAB)
            .setLabelColor(context.resources.getColor(R.color.textSectionColor))
            .setLabelBackgroundColor(Color.TRANSPARENT)
            .setLabelClickable(false)
            .create()
        **/
    }
    
    static func prepareFabHandlers(controller:HomePageViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        LST_SECTION.forEach { (section) in
            let fragmentSection = section.framentSection
            let targetAction = fragmentSection.rawValue
            //if section.fabItem.handler == nil {
                section.fabItem.handler = { item in
                    let target = storyboard.instantiateViewController(withIdentifier: targetAction) as! SICobroViewController
                    controller.onSectionChange(target: target, fragmentSection: section.framentSection)
                    controller.refreshHeader(fragmentSection: section.framentSection)
                    //controller.refreshFloatingMenu(section: section.framentSection)
                }
            //}
        }
    }
    
    static func hideFabItem(currentSection : FragmentSection?) {
        LST_SECTION.filter { (it) -> Bool in
            it.framentSection == currentSection
        }.forEach { (it2) in
            it2.fabItem.isHidden = true
        }
        
        LST_SECTION.filter { (it) -> Bool in
            it.framentSection != currentSection
        }.forEach { (it2) in
            it2.fabItem.isHidden = false
        }
    }
    
    static func getFabItems(currentSection : FragmentSection?) -> [FloatyItem] {
        let lst = LST_SECTION.filter { (it) -> Bool in
            it.framentSection != currentSection && it.enabled
        }.map { (it2) -> FloatyItem in
            it2.fabItem
        }
        return lst
    }

    /*
    func getSectionByFabItemId( itemId : Int) : SectionSiCobro {
        var index = LST_SECTION.indexOfFirst{ it.fabItem.id == itemId }
        return LST_SECTION[index]
    }
     */
    
    /*
     *
     */
    func setModuleEnablement(enabledModules: EnabledModules) -> SectionSiCobro {
        switch (framentSection) {
            case .COBROS:         self.enabled = enabledModules.cardPaymentEnabled ?? false; break;
            case .RECARGAS:       self.enabled = enabledModules.taeEnabled ?? false; break;
            case .PAGO_SERVICIOS: self.enabled = enabledModules.paymentServicesEnabled ?? false; break;
            case .REPORTES:       self.enabled = true; break;
            
            //case .none:break;
            case .MENU:break;
            case .CONTACT:break;
            case .NONE:break;
        }
        return self
    }

    /*
     *
     */
    func getControllerIdentifier() -> String? {
        return self.framentSection.rawValue ?? nil
    }
}



//var fabItem : SpeedDialActionItem) {
