//
//  CustomImagePopup.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 31/05/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Foundation

import UIKit

class CustomImagePopup: UIImageView {
    var tempRect: CGRect?
    var bgView: UIView!
    
    var animated: Bool = true
    var intDuration = 0.5
    //MARK: Life cycle
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CustomImagePopup.popUpImageToFullScreen))
        self.addGestureRecognizer(tapGesture)
        self.isUserInteractionEnabled = true
        //        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Actions of Gestures
    @objc func exitFullScreen () {
        let imageV = bgView.subviews[0] as! UIImageView
        
        UIView.animate(withDuration: intDuration, animations: {
                imageV.frame = self.tempRect!
                self.bgView.alpha = 0
            }, completion: { (bol) in
                self.bgView.removeFromSuperview()
        })
    }
    
    @objc func popUpImageToFullScreen() {
        
        if let window = UIApplication.shared.delegate?.window {
            let parentView = self.findParentViewController(self)!.view
            
            bgView = UIView(frame: UIScreen.main.bounds)
            bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CustomImagePopup.exitFullScreen)))
            bgView.alpha = 0
            bgView.backgroundColor = UIColor.black.withAlphaComponent(0.75)
            
            let imageV = UIImageView(image: self.image)
            let point = self.convert(self.bounds, to: parentView)
            imageV.frame = point
            tempRect = point
            imageV.contentMode = .scaleAspectFit
            self.bgView.addSubview(imageV)
            window?.addSubview(bgView)
            
            if animated {
                UIView.animate(withDuration: intDuration, animations: {
                    self.bgView.alpha = 1
                    imageV.frame = CGRect(x: 0, y: 0, width: (parentView?.frame.width)!, height: (parentView?.frame.width)!)
                    imageV.center = (parentView?.center)!
                })
            }
        }
    }
    
    func findParentViewController(_ view: UIView) -> UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
