//
//  ResetPasswordFormViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 20/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit

class ResetPasswordFormViewController: AbstractAuthenticationViewController {
    
    var subjectLabel : UILabel = {
           let lbl = UILabel()
           lbl.textColor = UIColor(named: "colorPrimaryDark")
           lbl.font = UIFont.boldSystemFont(ofSize: 15)
           lbl.textAlignment = .center
           lbl.numberOfLines = 0
           lbl.minimumScaleFactor = 0.5
           lbl.adjustsFontSizeToFitWidth = true
           lbl.sizeToFit()
           return lbl
       }()
    
    var npRedId : IconedUITextField = {
        let input = IconedUITextField()
        input.leftImage = UIImage(named: "id")
        input.borderColor = UIColor(named: "colorPrimaryDark")
        input.cornerRadius = 6.0
        input.borderWidth = 1.0
        input.maxLength = 9
        input.leftPadding = 5.0
        input.tag = 0
        input.placeholder = "No de RED / StoreID"
        input.font = UIFont.systemFont(ofSize: 17)
        input.textAlignment = .left
        input.valueType = .alphaNumeric
        input.returnKeyType = UIReturnKeyType.next
        //input.adjustFont()
        return input
    }()
    
    var npUser : IconedUITextField = {
        let input = IconedUITextField()
        input.leftImage = UIImage(named: "user")
        input.borderColor = UIColor(named: "colorPrimaryDark")
        input.cornerRadius = 6.0
        input.borderWidth = 1.0
        input.leftPadding = 5.0
        input.tag = 1
        input.placeholder = "Usuario"
        input.font = UIFont.systemFont(ofSize: 17)
        input.textAlignment = .left
        input.valueType = .alphaNumeric
        input.returnKeyType = UIReturnKeyType.done
        //input.adjustFont()
        return input
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(subjectLabel)
        view.addSubview(npRedId)
        view.addSubview(npUser)
        
        //view.frame.size.height = 150.0
        
        subjectLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subjectLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subjectLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subjectLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            //directionView.bottomAnchor.constraint(equalTo: filterView.topAnchor),
            subjectLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25)
        ])
        
        npRedId.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            npRedId.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            npRedId.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            npRedId.topAnchor.constraint(equalTo: subjectLabel.bottomAnchor, constant: 20),
            npRedId.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2)
            //npRedId.heightAnchor.constraint(equalToConstant: 20.0)
            //emailInput.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            //filterView.heightAnchor.constraint(equalToConstant: 100.0)
        ])
        
        npUser.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            npUser.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            npUser.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            npUser.topAnchor.constraint(equalTo: npRedId.bottomAnchor, constant: 15),
            npUser.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2)
            //npUser.heightAnchor.constraint(equalToConstant: 20.0)
            //emailInput.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            //filterView.heightAnchor.constraint(equalToConstant: 100.0)
        ])
        
        let toolbar = self.getGenericFormToolbar()
        self.npRedId.inputAccessoryView = toolbar
        self.npUser.inputAccessoryView = toolbar
        //view.frame.size.height = titleLabel.frame.height + emailInput.frame.height + 20
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.npRedId.adjustFont()
        self.npUser.adjustFont()
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
