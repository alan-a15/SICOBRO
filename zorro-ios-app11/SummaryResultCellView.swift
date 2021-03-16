//
//  SummaryResultCellView.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 13/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Foundation
import UIKit

class SummaryResultCellView : UITableViewCell {
    
    @IBOutlet weak var fieldName: UILabel!
    @IBOutlet weak var fieldValue: UILabel!
}

class CustomSummaryResultCellView : UITableViewCell {
    let fieldName: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.textAlignment = .left
        return lbl
    }()
    
    let fieldValue: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .black
        lbl.font = UIFont.systemFont(ofSize: 13)
        lbl.textAlignment = .left
        return lbl
    }()
    
    var widthValue1Per:CGFloat = 0.35
    var widthValue2Per:CGFloat = 0.65
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //let widthValue1 = frame.size.width * widthValue1Per
        //let widthValue2 = frame.size.width * widthValue2Per
        
        addSubview(fieldName)
        addSubview(fieldValue)
        
        setWidthPercentages(widhtp1: widthValue1Per, widhtp2: widthValue2Per)
    }
    
    func setWidthPercentages(widhtp1: CGFloat, widhtp2: CGFloat) {
        widthValue1Per = widhtp1
        widthValue2Per = widhtp2
        let widthValue1 = frame.size.width * widthValue1Per
        let widthValue2 = frame.size.width * widthValue2Per
        
        fieldName.translatesAutoresizingMaskIntoConstraints = false
        fieldName.frame.size.width = widthValue1
        fieldName.textAlignment = .left
        NSLayoutConstraint.activate([
            fieldName.topAnchor.constraint(equalTo: topAnchor),
            fieldName.leadingAnchor.constraint(equalTo: leadingAnchor),
            fieldName.bottomAnchor.constraint(equalTo: bottomAnchor),
            fieldName.heightAnchor.constraint(equalTo: heightAnchor),
            fieldName.widthAnchor.constraint(equalToConstant: widthValue1),
            //fieldName.centerYAnchor.constraint(equalTo: centerYAnchor),
            //label1.centerXAnchor.constraint(equalTo: centerXAnchor),
            //label1.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        fieldValue.translatesAutoresizingMaskIntoConstraints = false
        fieldValue.frame.size.width = widthValue2
        fieldValue.textAlignment = .left
        NSLayoutConstraint.activate([
            fieldValue.topAnchor.constraint(equalTo: topAnchor),
            fieldValue.leadingAnchor.constraint(equalTo: fieldName.trailingAnchor),
            fieldValue.trailingAnchor.constraint(equalTo: trailingAnchor),
            fieldValue.bottomAnchor.constraint(equalTo: bottomAnchor),
            fieldValue.heightAnchor.constraint(equalTo: heightAnchor),
            fieldValue.widthAnchor.constraint(equalToConstant: widthValue2),
            //fieldValue.centerYAnchor.constraint(equalTo: centerYAnchor),
            //label1.centerXAnchor.constraint(equalTo: centerXAnchor),
            //label1.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
