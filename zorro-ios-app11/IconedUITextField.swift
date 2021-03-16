//
//  IconedUITextField.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 12/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Foundation
import UIKit

enum ValueType: Int {
    case none
    case onlyLetters
    case onlyNumbers
    case currency
    case phoneNumber   // Allowed "+0123456789"
    case alphaNumeric
    case password
    case fullName       // Allowed letters and space
}

@IBDesignable
class IconedUITextField: UITextField {
    
    var valueType: ValueType = ValueType.none
    
    var passwordHideImage:UIImage? = UIImage(named: "hide_pass")
    var passwordShowImage:UIImage? = UIImage(named: "view_pass")
    var rightDrawed:Bool = false
    var imageSize:CGFloat = 25.0
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }

    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
    
    @IBInspectable var leftPadding: CGFloat = 0
    @IBInspectable var rightPadding: CGFloat = 0
    @IBInspectable var maxLength: Int = 0
    
    @IBInspectable var leftImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var rightImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var color: UIColor = UIColor.lightGray {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var tooglePassword: Bool = false {
        didSet {
            if valueType == .password {
                rightImage = isSecureTextEntry ? passwordShowImage : passwordHideImage
                updateView()
            }
        }
    }
    
    @objc func toggleInput() {
        isSecureTextEntry = !isSecureTextEntry
        tooglePassword = !tooglePassword
    }
    
    // Provides left padding for images
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += leftPadding
        return textRect
    }
    
    // Provides right padding for images
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        //debugPrint("On rightViewRect")
        var textRect = super.rightViewRect(forBounds: bounds)
        if !rightDrawed {
            textRect.size.width = textRect.size.width + rightPadding
            rightDrawed = true
        }
        return textRect
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.editingRect(forBounds: bounds)
        if rightImage != nil {
            textRect.size.width -= rightPadding
        }
        return textRect
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.textRect(forBounds: bounds)
        if rightImage != nil {
            textRect.size.width -= rightPadding
        }
        return textRect
    }
    
    func updateView() {
        if let image = leftImage {
            leftViewMode = UITextField.ViewMode.always
            //clearButtonMode = UITextField.ViewMode.always
            //let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.height / 2.0, height: self.frame.height / 2))
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            // Note: In order for your image to use the tint color, you have to select the image in the Assets.xcassets and change the "Render As" property to "Template Image".
            imageView.tintColor = color
            leftView = imageView
        } else {
            leftViewMode = UITextField.ViewMode.never
            leftView = nil
        }
        
        if let image = rightImage {
            rightViewMode = UITextField.ViewMode.always
            clearButtonMode = UITextField.ViewMode.always
            //let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.height / 2.0, height: self.frame.height / 2))
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            // Note: In order for your image to use the tint color, you have to select the image in the Assets.xcassets and change the "Render As" property to "Template Image".
            imageView.tintColor = color
            rightView = imageView
            clearButtonMode = .always
            if valueType == .password {
                let tap = UITapGestureRecognizer(target: self, action: #selector(toggleInput))
                rightView?.addGestureRecognizer(tap)
                rightView?.isUserInteractionEnabled = true
            }
        } else {
            rightViewMode = UITextField.ViewMode.never
            rightView = nil
        }
        
        // Placeholder text color
        attributedPlaceholder = NSAttributedString(string: placeholder != nil ?  placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: color])
    }
    
    func verifyFields(shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        switch valueType {
            case .none, .password:
                break // Do nothing
                
            case .onlyLetters:
                let characterSet = CharacterSet.letters
                if string.rangeOfCharacter(from: characterSet.inverted) != nil {
                    return false
                }
                
            case .onlyNumbers:
                let numberSet = CharacterSet.decimalDigits
                if string.rangeOfCharacter(from: numberSet.inverted) != nil {
                    return false
                }
                
            case .phoneNumber:
                let phoneNumberSet = CharacterSet(charactersIn: "+0123456789")
                if string.rangeOfCharacter(from: phoneNumberSet.inverted) != nil {
                    return false
                }
            
            case .currency:
                let currencySet = CharacterSet(charactersIn: ".0123456789")
                if string.rangeOfCharacter(from: currencySet.inverted) != nil {
                    return false
                }
                
            case .alphaNumeric:
                let alphaNumericSet = CharacterSet.alphanumerics
                if string.rangeOfCharacter(from: alphaNumericSet.inverted) != nil {
                    return false
                }
                
            case .fullName:
                var characterSet = CharacterSet.letters
                print(characterSet)
                characterSet = characterSet.union(CharacterSet(charactersIn: " "))
                if string.rangeOfCharacter(from: characterSet.inverted) != nil {
                    return false
                }
        }
        
        guard let textFieldText = self.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        
        if( maxLength > 0 ) {
            let substringToReplace = textFieldText[rangeOfTextToReplace]
            let count = textFieldText.count - substringToReplace.count + string.count
            return count <= maxLength
        }
        
        return true
        
        /*
        if let text = self.text, let textRange = Range(range, in: text) {
            let finalText = text.replacingCharacters(in: textRange, with: string)
            if maxLength > 0, maxLength < finalText.utf8.count {
                return false
            }
        }
        return true
         */
    }
    
    func adjustFont(scale : CGFloat = 2.0) {
        self.font = UIFont.systemFont(ofSize: self.frame.height / scale)
    }
    
}

