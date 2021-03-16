//
//  DetailRecordViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 18/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit

class DetailRecordViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var detailRecord: UITableView = UITableView()
    
    var summaryValues : [SummaryItem]?
    var heightOfTableViewConstraint:NSLayoutConstraint?
    var estimatedHeightTable : CGFloat?
    var estimatedRowSize : CGFloat = 17.0
    var itemHeight:CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        debugPrint("[DetailRecordViewController] viewDidLoad")
        detailRecord.register(CustomSummaryResultCellView.self, forCellReuseIdentifier: "popupRowCell")
        detailRecord.backgroundColor = UIColor(named: "backgroundTable")
        detailRecord.estimatedRowHeight = UITableView.automaticDimension
        
        view.backgroundColor = UIColor(named: "helperColor")
        
        view.addSubview(detailRecord)
        detailRecord.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            detailRecord.topAnchor.constraint(equalTo: view.topAnchor),
            detailRecord.leftAnchor.constraint(equalTo: view.leftAnchor),
            detailRecord.rightAnchor.constraint(equalTo: view.rightAnchor),
            detailRecord.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        detailRecord.tableFooterView = UIView()
        detailRecord.dataSource = self
        //detailRecord.reloadData()
        
        /*
        heightOfTableViewConstraint = NSLayoutConstraint(item: self.detailRecord, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.0, constant: 1000)
        view.addConstraint(heightOfTableViewConstraint!)
        if let summaryValues = summaryValues {
            estimatedHeightTable = estimatedRowSize * CGFloat(summaryValues.count)
            self.heightOfTableViewConstraint!.constant = estimatedHeightTable!
            //detailRecord.sizeToFit()
            //view.sizeToFit()
            view.frame.size.height = estimatedHeightTable!
        }
         */
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let frameSize:CGFloat = view.frame.height
        itemHeight = CGFloat(detailRecord.frame.height) / CGFloat(summaryValues!.count)
        print("[ContactUsViewController] Total height of screen: \(frameSize)")
        print("[ContactUsViewController] Height of contactList: \(detailRecord.frame.height)")
        print("[ContactUsViewController] Calculated Height \(itemHeight)")
        detailRecord.rowHeight = CGFloat(itemHeight)
        detailRecord.estimatedRowHeight = CGFloat(itemHeight)
        detailRecord.reloadData()
    }
    
    /*
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return UITableView.automaticDimension
    }
     */
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return itemHeight
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return itemHeight
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let summaryValues = summaryValues else {
            return 0
        }
        print("[DetailRecordViewController] Couint \(summaryValues.count)")
        return summaryValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("[DetailRecordViewController] Item row \(indexPath.row)")
        let cell : CustomSummaryResultCellView = self.detailRecord.dequeueReusableCell(withIdentifier: "popupRowCell") as! CustomSummaryResultCellView
        cell.backgroundColor = UIColor(named: "backgroundTable")
        guard let summaryValues = summaryValues else {
            return cell
        }
        let item:SummaryItem = summaryValues[indexPath.row]
        print("[DetailRecordViewController] item name \(item.name)")
        print("[DetailRecordViewController] item value \(item.value)")
        
        cell.fieldName.text = item.name
        cell.fieldName.textColor = UIColor(named: "colorPrimaryDark")
        cell.fieldName.font = UIFont.boldSystemFont(ofSize: 14.0)
        cell.fieldValue.text = item.value
        cell.fieldValue.textColor = UIColor(named: "nonSelectedText")
        cell.fieldValue.font = UIFont.systemFont(ofSize: 14.0)
        cell.fieldValue.numberOfLines = 0
        cell.fieldValue.adjustsFontSizeToFitWidth = true
        cell.layoutIfNeeded()
        
        return cell
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
