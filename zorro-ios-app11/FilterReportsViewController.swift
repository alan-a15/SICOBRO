//
//  FilterReportsViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 17/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit
import Alamofire
import RadioGroup

class FilterReportsViewController: AbstractUIViewController,UIPickerViewDelegate, UIPickerViewDataSource {

    //var directionPicker: UIPickerView?
    //var filterPicker: UIPickerView?
    
    @IBOutlet weak var filterPicker: UIPickerView!
    @IBOutlet weak var directionPicker: UIPickerView!
    
    @IBOutlet weak var directionRadio: RadioGroup!
    @IBOutlet weak var filterRadio: RadioGroup!
    
    var directionWrapper:PickerWrapper = PickerWrapper()
    var filterWrapper:PickerWrapper = PickerWrapper()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint("FilterReportsViewController viewDidLoad")
        //view.frame = CGRect(x:0, y: 0, width:view.frame.size.width - 30, height:view.frame.size.height / 2)
        
        //directionPicker = UIPickerView()
        //directionPicker.tag = 1
        //filterPicker = UIPickerView()
        //filterPicker.tag = 2
        
        directionRadio.tag = 1
        filterRadio.tag = 2
        
        // NOTE: UNCOMMENT IF YOU STILL NEED PICKERS
        /*
        directionPicker.delegate = self
        directionPicker.dataSource = self
        // To make the selectRow work, it should be called before add picker to view
        debugPrint("Selected Direction option: \(directionWrapper.selectedItemIndex)")
        directionPicker.selectRow(directionWrapper.selectedItemIndex, inComponent: 0, animated: true)
        pickerView(directionPicker, didSelectRow:directionWrapper.selectedItemIndex, inComponent: 0)
        directionPicker.reloadAllComponents()
        directionWrapper.picker = directionPicker
         */
        
        let radioSize = getRadioSize()
        
        directionRadio.titles = directionWrapper.elements
        directionRadio.selectedIndex = directionWrapper.selectedItemIndex
        directionRadio.addTarget(self, action: #selector(directionOptionSelected), for: .valueChanged)
        directionRadio.tintColor = UIColor(named: "nonSelectedText")
        directionRadio.titleColor = UIColor(named: "colorPrimaryDark")
        directionRadio.selectedColor = UIColor(named: "nonSelectedText")
        directionRadio.buttonSize = radioSize
        directionWrapper.radioGroup = directionRadio
        
        
        // NOTE: UNCOMMENT IF YOU STILL NEED PICKERS
        /*
        filterPicker.delegate = self
        filterPicker.dataSource = self
        // To make the selectRow work, it should be called before add picker to view
        debugPrint("Selected Filter option: \(filterWrapper.selectedItemIndex)")
        filterPicker.selectRow(filterWrapper.selectedItemIndex, inComponent: 0, animated: true)
        pickerView(filterPicker, didSelectRow:filterWrapper.selectedItemIndex, inComponent: 0)
        filterPicker.reloadAllComponents()
        filterWrapper.picker = filterPicker
         */
        
        filterRadio.titles = filterWrapper.elements
        filterRadio.selectedIndex = filterWrapper.selectedItemIndex
        filterRadio.addTarget(self, action: #selector(filterOptionSelected), for: .valueChanged)
        filterRadio.tintColor = UIColor(named: "nonSelectedText")
        filterRadio.titleColor = UIColor(named: "colorPrimaryDark")
        filterRadio.selectedColor = UIColor(named: "nonSelectedText")
        filterRadio.buttonSize = radioSize
        filterWrapper.radioGroup = filterRadio
        //self.pickerView(directionWrapper.picker!, didSelectRow: directionWrapper.selectedItemIndex, inComponent: 0)
        //self.pickerView(filterWrapper.picker!, didSelectRow: filterWrapper.selectedItemIndex, inComponent: 0)
        
        /*
        let directionView = createFilterSection(sicon: "sort", slabel: "Ordenar", picker: directionPicker!)
        view.addSubview(directionView)
        directionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            directionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            directionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            directionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8.0),
            //directionView.bottomAnchor.constraint(equalTo: filterView.topAnchor),
            directionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5, constant: 0),
        ])
        
        let filterView = createFilterSection(sicon: "filter", slabel: "Filtrar", picker: filterPicker!)
        view.addSubview(filterView)
        filterView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterView.topAnchor.constraint(equalTo: directionView.bottomAnchor, constant: 4.0),
            filterView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8.0),
            filterView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5, constant: 0),
        ])
         */
        
        // NOTE: UNCOMMENT IF YOU STILL NEED PICKERS
        /*
        //directionPicker.selectRow(directionWrapper.selectedItemIndex, inComponent: 0, animated: true)
        //filterPicker.selectRow(filterWrapper.selectedItemIndex, inComponent: 0, animated: true)
         */
        
        //view.sizeToFit()
        
        /*
        directionViewConstraint = NSLayoutConstraint(item: directionView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.0, constant: 1000)
        view.addConstraint(directionViewConstraint!)
        filterViewConstraint = NSLayoutConstraint(item: filterView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.0, constant: 1000)
        view.addConstraint(filterViewConstraint!)
        
        self.directionViewConstraint!.constant = directionView.frame.height
        self.filterViewConstraint!.constant = filterView.frame.height
         */
        
        //view.frame.size.height = directionView.frame.height + filterView.frame.height + 20.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /*
        filterPicker.selectRow(filterWrapper.selectedItemIndex, inComponent: 0, animated: true)
        pickerView(filterPicker, didSelectRow:filterWrapper.selectedItemIndex, inComponent: 0)
        filterPicker.reloadAllComponents()
        
        directionPicker.selectRow(directionWrapper.selectedItemIndex, inComponent: 0, animated: true)
        pickerView(directionPicker, didSelectRow:directionWrapper.selectedItemIndex, inComponent: 0)
        directionPicker.reloadAllComponents()
         */
    }
    
    func getRadioSize() -> CGFloat {
        switch UIScreen.main.nativeBounds.height {
            case 1136:
                return 15.0
                /*
            case 1334:
                return .iPhones_6_6s_7_8
            case 1792:
                return .iPhone_XR_11
            case 1920, 2208:
                return .iPhones_6Plus_6sPlus_7Plus_8Plus
            case 2426:
                return .iPhone_11Pro
            case 2436:
                return .iPhones_X_XS
            case 2688:
                return .iPhone_XSMax_ProMax
                */
            default:
                return 20.0
        }
    }
    
    func setDirectionOptions(directionOptions:[String]) {
        directionWrapper.elements = directionOptions
    }
    
    func setFilterOptions(filterOptions:[String]) {
        filterWrapper.elements = filterOptions
    }
    
    @objc func directionOptionSelected() {
        if let sindex = directionRadio?.selectedIndex {
            directionWrapper.selectedItemIndex = sindex
        }
        directionWrapper.selectedItem = directionWrapper.elements[directionWrapper.selectedItemIndex ]
    }
    
    @objc func filterOptionSelected() {
        if let sindex = filterRadio?.selectedIndex {
            filterWrapper.selectedItemIndex = sindex
        }
        filterWrapper.selectedItem = filterWrapper.elements[filterWrapper.selectedItemIndex ]
    }
    
    func createFilterSection(sicon: String, slabel:String, picker:UIPickerView) -> UIView {
        let containerView = UIView(frame: view.bounds)
        let titleFilter:UILabel = UILabel()
        titleFilter.text = slabel
        titleFilter.textAlignment = .left
        titleFilter.font = UIFont.systemFont(ofSize: 16.0)
        let icon:UIImageView = UIImageView()
        let imageIcon = UIImage(named: sicon)
        icon.image = imageIcon
        
        containerView.addSubview(icon)
        containerView.addSubview(titleFilter)
        containerView.addSubview(picker)
        
        //picker.frame.size.height = 80.0
    
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.frame.size.width = 30.0
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            //icon.trailingAnchor.constraint(equalTo: titleFilter.leadingAnchor),
            icon.topAnchor.constraint(equalTo: containerView.topAnchor),
            icon.widthAnchor.constraint(equalToConstant: 30.0),
            icon.bottomAnchor.constraint(equalTo: picker.topAnchor)
        ])
        
        titleFilter.translatesAutoresizingMaskIntoConstraints = false
        titleFilter.frame.size.width = view.frame.width - 30
        NSLayoutConstraint.activate([
            titleFilter.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 20),
            titleFilter.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            titleFilter.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleFilter.bottomAnchor.constraint(equalTo: picker.topAnchor)
        ])
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            picker.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            picker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            //picker.topAnchor.constraint(equalTo: titleFilter.bottomAnchor),
            picker.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            picker.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 0.8)
        ])
        
        return containerView
    }
    
    func getCallbackFilterAvailableOptions(controller: AbstractReportViewController) -> RestCallback<[AvailableOption]> {
        let onResponse : (([AvailableOption]?) -> ())? = { response in
            debugPrint("response \(String(describing: response))")
            if let availableOptions = response {
                let options:[String] = availableOptions.map { (it) -> String in
                    (it.name ?? "--")
                }
                self.setFilterOptions(filterOptions: options)
                if self.filterPicker != nil {
                    self.filterPicker?.reloadAllComponents()
                }
                if self.filterRadio != nil {
                    self.filterRadio.titles = options
                }
                controller.filterAvailableOptions = response
            }
        }
        
        let apiError : ((ApiError)->())? =  { apiError in
            let smsg = "Ocurrio un error obteniendo los ultimos reportes."
            guard let msg = apiError.message else {
                self.showAlert(message: smsg)
                debugPrint("\(smsg)")
                return
            }
            self.showAlert(message: "\(smsg): \(msg)")
            debugPrint("\(smsg): \(msg)")
        }
        
        let onFailure : ((AFError?,HTTPURLResponse?)->())? = { (error, response) in
            let smsg = "Ocurrio un error obteniendo los ultimos reportes."
            guard let msg = error?.errorDescription else {
                self.showAlert(message: smsg)
                debugPrint("\(smsg)")
                return
            }
            self.showAlert(message: "\(smsg): \(msg)")
            debugPrint("\(smsg): \(msg)")
        }
          
        return RestCallback<[AvailableOption]>(onResponse: onResponse,
                                                onApiError: apiError,
                                                onFailure: onFailure)
    }
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let wrapper = getWrapperByTag(tag: pickerView.tag) {
            return wrapper.elements.count + 1
        }
        return 0
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let wrapper = getWrapperByTag(tag: pickerView.tag) {
            wrapper.selectedItemIndex = (row - 1)
            if wrapper.selectedItemIndex >= 0 {
                return wrapper.elements[wrapper.selectedItemIndex]
            }
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let wrapper = getWrapperByTag(tag: pickerView.tag) {
            wrapper.selectedItemIndex = (row - 1)
            if wrapper.selectedItemIndex >= 0 {
                wrapper.selectedItem = wrapper.elements[wrapper.selectedItemIndex]
            }
        }
    }
    
    private func getWrapperByTag(tag:Int) -> PickerWrapper? {
        if tag == directionWrapper.picker?.tag {
            return directionWrapper
        } else if tag == filterWrapper.picker?.tag {
            return filterWrapper
        }
        return nil
    }
}

class PickerWrapper {
    var picker: UIPickerView?
    var radioGroup: RadioGroup?
    var elements:[String] = []
    var selectedItemIndex:Int = 0
    var selectedItem:String?
}
