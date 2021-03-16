//
//  SendReceiptViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 19/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit

class SendReceiptViewController: SICobroViewController {

    var titleLabel : UILabel = {
           let lbl = UILabel()
           lbl.textColor = UIColor(named: "colorPrimaryDark")
           lbl.font = UIFont.boldSystemFont(ofSize: 15.0)
           lbl.textAlignment = .center
           lbl.numberOfLines = 0
           lbl.sizeToFit()
           return lbl
       }()
    
    var emailInput : IconedUITextField = {
        let input = IconedUITextField()
        input.textColor = UIColor(named: "colorPrimaryDark")
        input.font = UIFont.systemFont(ofSize: 18.0)
        input.textAlignment = .center
        input.leftImage = UIImage(named: "mobile")
        input.leftPadding = 5.0
        input.valueType = .alphaNumeric
        input.placeholder = "EMAIL"
        input.borderWidth = 1.0
        input.cornerRadius = 5.0
        input.borderColor = UIColor(named: "colorPrimaryDark")
        return input
    }()
    
    var customerReceiptRequest:CustomerReceiptRequest = CustomerReceiptRequest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint("customerReceiptRequest.clientUUID: \(customerReceiptRequest.clientUUID)")
        debugPrint("customerReceiptRequest.janoUUID: \(customerReceiptRequest.janoUUID ?? "--")")
        
        view.addSubview(titleLabel)
        view.addSubview(emailInput)
        
        //view.frame.size.height = 200.0
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.frame.size.height = 20.0
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            //directionView.bottomAnchor.constraint(equalTo: filterView.topAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 20.0)
        ])
        
        emailInput.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emailInput.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emailInput.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emailInput.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20.0),
            emailInput.heightAnchor.constraint(equalToConstant: 35.0)
            //emailInput.heightAnchor.constraint(equalToConstant: emailInput.frame.height)
            //emailInput.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            //filterView.heightAnchor.constraint(equalToConstant: 100.0)
        ])
        //view.frame.size.height = titleLabel.frame.height + emailInput.frame.height + 20.0
        let toolbar = self.getGenericFormToolbar()
        self.emailInput.inputAccessoryView = toolbar
        self.emailInput.inputAccessoryView = toolbar
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
