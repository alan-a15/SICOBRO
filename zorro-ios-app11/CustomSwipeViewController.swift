//
//  CustomSwipeViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 14/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit

extension CustomSwipeViewController : UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
}

class CustomSwipeViewController: SwipeMenuViewController {

    var observer : NSObjectProtocol?
    var options = SwipeMenuViewOptions()
    var parentController :SICobroViewController?
    var currentController : AbstractReportViewController?
    
    let MAX_DAYS_CONSULT = 30
    
    var formatter : DateFormatter {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yy"
            return formatter
        }
    }
    
    var content : UIView! {
        didSet {
            //content.frame = self.view.bounds
            content.frame.size.width = self.view.frame.width - 40
            //content.backgroundColor = .blue
        }
    }
    
    var endDateField: IconedUITextField! {
        didSet {
            content.addSubview(endDateField)
            endDateField.translatesAutoresizingMaskIntoConstraints = false
            endDateField.backgroundColor = .white
            endDateField.borderStyle = .roundedRect
            endDateField.leftImage = UIImage(named: "date")
            endDateField.leftPadding = 0.0
            endDateField.rightImage = UIImage(named: "arrow_down")
            endDateField.rightPadding = 0.0
            endDateField.font = UIFont.systemFont(ofSize: 15.0)
            endDateField.adjustsFontSizeToFitWidth = true
            endDateField.sizeToFit()
            endDateField.delegate = self
            //endDateField.frame.size.width = CGFloat(50)
            endDateField.isEnabled = true
            endDateField.text = formatter.string(from: Date())
            endDateField.textAlignment = .center
            NSLayoutConstraint.activate([
                endDateField.topAnchor.constraint(equalTo: content.topAnchor),
                endDateField.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: 0),
                endDateField.bottomAnchor.constraint(equalTo: content.bottomAnchor),
                //endDateField.heightAnchor.constraint(equalToConstant: options.tabView.height),
                endDateField.heightAnchor.constraint(equalTo: content.widthAnchor, multiplier: 0.125),
                endDateField.widthAnchor.constraint(equalTo: content.widthAnchor, multiplier: 0.45)
            ])
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(showEndDatepicker))
            endDateField.addGestureRecognizer(tap)
            endDateField.isUserInteractionEnabled = true
            //endDateField.adjustFont()
            content.bringSubviewToFront(endDateField)
        }
    }
    
    var startDateField: IconedUITextField! {
        didSet {
            content.addSubview(startDateField)
            startDateField.translatesAutoresizingMaskIntoConstraints = false
            startDateField.backgroundColor = .white
            startDateField.borderStyle = .roundedRect
            startDateField.leftImage = UIImage(named: "date")
            startDateField.leftPadding = 0.0
            startDateField.rightImage = UIImage(named: "arrow_down")
            startDateField.rightPadding = 0.0
            startDateField.adjustsFontSizeToFitWidth = true
            startDateField.sizeToFit()
            startDateField.font = UIFont.systemFont(ofSize: 15.0)
            startDateField.delegate = self
            //startDateField.frame.size.width = CGFloat(50)
            startDateField.isEnabled = true
            startDateField.text = formatter.string(from: Date())
            startDateField.textAlignment = .center
            NSLayoutConstraint.activate([
                startDateField.topAnchor.constraint(equalTo: content.topAnchor),
                startDateField.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 0),
                startDateField.bottomAnchor.constraint(equalTo: content.bottomAnchor),
                //startDateField.heightAnchor.constraint(equalToConstant: options.tabView.height),
                startDateField.heightAnchor.constraint(equalTo: content.widthAnchor, multiplier: 0.125),
                startDateField.widthAnchor.constraint(equalTo: content.widthAnchor, multiplier: 0.45)
            ])
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(showStartDatepicker))
            startDateField.addGestureRecognizer(tap)
            startDateField.isUserInteractionEnabled = true
            //startDateField.adjustFont()
            content.bringSubviewToFront(startDateField)
        }
    }
    
    @objc func showStartDatepicker() {
        showDatepicker(dateField: self.startDateField, isEndDate: false)
    }
    
    @objc func showEndDatepicker() {
        showDatepicker(dateField: self.endDateField, isEndDate: true)
    }
        
    func showDatepicker(dateField : IconedUITextField, isEndDate : Bool) {
        print("On showDatepicker")
        //parentController?.showAlert(message: "Aaction enabled")
        
        let storyboard = UIStoryboard(name: "CustomPopup" , bundle: nil)
        let popup = storyboard.instantiateInitialViewController() as! CustomPopUpViewController
        popup.customTitle = "Selecciona una fecha"
        popup.isDatePicker = true
        if(isEndDate) {
            let currentTime = Date()
            var dDate:Date = Date()
            if let sdate = startDateField.text {
                dDate = formatter.date(from: sdate)!
            }
            popup.minDate = dDate
            
            let mdate = dDate.addingTimeInterval( TimeInterval(MAX_DAYS_CONSULT * 60 * 60 * 24) )
            popup.maxDate = (mdate.timeIntervalSince1970 > currentTime.timeIntervalSince1970) ?
                            currentTime : mdate
        }
        
        if let sdate = dateField.text {
            popup.cDate = formatter.date(from: sdate)!
        }
        
        popup.positiveButtonLabel = "Aceptar"
        popup.negativeButtonLabel = "Cancelar"
        popup.observerId = .datePicker
        observer = NotificationCenter.default.addObserver(forName: .datePicker, object: nil, queue: OperationQueue.main, using:
                   { (notification) in
                       // Action received from popup
                       let dateSelected = notification.object as! String // Expect an integer fromn the list
                        guard !dateSelected.isEmpty else {
                            print("No data received from Chooser")
                            return
                        }
                        // Dates logic
                        dateField.text = dateSelected
                        if(!isEndDate) {
                            let currentTime = Date()
                            let sdate = self.formatter.date(from: dateSelected)!
                            let mdate = sdate.addingTimeInterval( TimeInterval(self.MAX_DAYS_CONSULT * 60 * 60 * 24) )
                            let maxDate = (mdate.timeIntervalSince1970 > currentTime.timeIntervalSince1970) ? currentTime : mdate
                            self.endDateField.text = self.formatter.string(from: maxDate)
                        }
                       
                        // Unregister observer
                        if let mobserver = self.observer {
                             NotificationCenter.default.removeObserver(mobserver)
                             self.observer = nil
                        }
                    
                        self.triggerChangeDate()
               })
        popup.controller = self
        self.present(popup, animated: true)
    }
    
    private func triggerChangeDate() {
        debugPrint("On triggerChangeDate")
        if ( validateDates() ) {
            debugPrint("currentController \(currentController)")
            debugPrint("currentController Name \(currentController?.title)")
            if let currentController = currentController {
                if let startd = startDateField.text, let endd = endDateField.text {
                    debugPrint("Invoking onFilterDatesChange")
                    currentController.onFilterDatesChange(newStartDate: startd,
                                                          newEndDate: endd)
                }
            }
        }
    }
    
    /*
     * TO-DO: Validate exhasustive the date fields
     */
    private func validateDates() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        content = UIView()
        startDateField = IconedUITextField()
        endDateField = IconedUITextField()
        
        TabReportSection.getTabsReports(enabledModules: nil).forEach { (it) in
            var controller:AbstractReportViewController?
            switch(it.section) {
                case .RECARGAS:
                    controller = ReportRecargasViewController(tabName: "Recargas")
                    currentController = controller
                    debugPrint("Creating regarcas controller: \(currentController)")
                    break;
                case .some(.COBROS):
                    controller = ReportBPTransactionsViewController(tabName: "Cobros")
                    break;
                case .some(.PAGO_SERVICIOS):
                    controller = ReportServicesViewController(tabName: "Pago de Servicios")
                    break;
                case .none:
                    break;
                case .NONE:
                    break;
                case .some(.MENU):
                    break;
                case .some(.CONTACT):
                    break;
                case .some(.REPORTES):
                    break;
            }
            controller!.title = it.name
            controller!.sstartDate = startDateField.text ?? formatter.string(from: Date())
            controller!.sendDate = endDateField.text ?? formatter.string(from: Date())
            self.addChild(controller!)
        }
        
        options.tabView.backgroundColor = UIColor(named: "colorPrimaryDark")!
        options.tabView.style = .segmented
        options.tabView.additionView.backgroundColor = UIColor(named: "colorPrimary")!
        options.tabView.itemView.selectedTextColor = UIColor(named: "textSectionColor")!
        options.tabView.itemView.textColor = UIColor(named: "nonSelectedText")!
        
        super.customMiddleView = content
        
        super.viewDidLoad()
        swipeMenuView.reloadData(options: options)
        
        endDateField.adjustFont(scale: 3.0)
        startDateField.adjustFont(scale: 3.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        swipeMenuView.layoutIfNeeded()
        view.layoutIfNeeded()
    }
    
    // MARK: - SwipeMenuViewDelegate

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewWillSetupAt currentIndex: Int) {
        super.swipeMenuView(swipeMenuView, viewWillSetupAt: currentIndex)
        print("will setup SwipeMenuView")
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewDidSetupAt currentIndex: Int) {
        super.swipeMenuView(swipeMenuView, viewDidSetupAt: currentIndex)
        print("did setup SwipeMenuView")
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, willChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        super.swipeMenuView(swipeMenuView, willChangeIndexFrom: fromIndex, to: toIndex)
        print("will change from section\(fromIndex + 1)  to section\(toIndex + 1)")
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        super.swipeMenuView(swipeMenuView, didChangeIndexFrom: fromIndex, to: toIndex)
        print("did change from section\(fromIndex + 1)  to section\(toIndex + 1)")
        currentController = children[toIndex] as? AbstractReportViewController
    }


    // MARK - SwipeMenuViewDataSource

    override func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        return TabReportSection.TABS_REPORTS.count
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        return children[index].title ?? ""
    }

    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
        let vc = children[index] as? AbstractReportViewController
        vc?.didMove(toParent: self)
        return vc!
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
