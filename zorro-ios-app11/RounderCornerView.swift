//
//  RounderCornerView.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 29/03/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit

// To allow Xcode that it needs to render the view properties directly in the Interface builder.
@IBDesignable
class RounderCornerView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var topBorderColor: UIColor = .black {
        didSet {
            let thickness: CGFloat = 2.0
            let topBorder = CALayer()
            
            topBorder.frame = CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: thickness)
            topBorder.backgroundColor = topBorderColor.cgColor
            layer.addSublayer(topBorder)
        }
    }
    
    @IBInspectable var bottomBorderColor: UIColor = .black {
        didSet {
            let thickness: CGFloat = 2.0
            let border = CALayer()
            border.frame = CGRect(x:0, y: frame.size.height - thickness, width: frame.size.width, height:thickness)
            border.backgroundColor = bottomBorderColor.cgColor
            
            layer.addSublayer(border)
        }
    }
    
    @IBInspectable var leftBorderColor: UIColor = .black {
        didSet {
            let thickness: CGFloat = 2.0
            let border = CALayer()
            border.frame = CGRect(x:0, y: 0, width: thickness, height:frame.size.height)
            border.backgroundColor = bottomBorderColor.cgColor
            
            layer.addSublayer(border)
        }
    }

}
