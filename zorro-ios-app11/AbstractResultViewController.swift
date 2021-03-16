//
//  AbstractResultViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 13/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit
import SwiftGifOrigin

protocol PostOperationAction {
    func postAction(abstractResultViewController : AbstractResultViewController)
}

class AbstractResultViewController: SICobroViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var resultTitle: UILabel!
    
    @IBOutlet weak var resultImg: UIImageView!
    
    @IBOutlet weak var resultMsg: UILabel!
    
    @IBOutlet weak var resultSummary: UITableView!
    
    @IBOutlet weak var repeatButton: CustomRoundedButton!
    
    @IBOutlet weak var postActionButton: CustomRoundedButton!
    
    @IBOutlet weak var summayConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var postActionHeighConstraint: NSLayoutConstraint!
    
    var resultTitleTxt : String?
    var repeatButtonTxt : String?
    var targetAction : String?
    var fragmentSection:FragmentSection?
    var resultMsgTxt : String?
    var success : Bool = false
    var summaryValues : [SummaryItem]?
    var postOperationAction:PostOperationAction?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.postOperationAction != nil && success {
            postActionButton.isHidden = false
            postActionButton.adjustFont(scale: 3.0)
        } else {
            postActionButton.isHidden = true
            postActionButton.isEnabled = false
            postActionButton.frame.size.height = 0.0
            //postActionButton.removeFromSuperview()
            DispatchQueue.main.async {
                //self.summayConstraint.constant = 0
                //self.resultSummary.layoutIfNeeded()
                self.postActionHeighConstraint.changeMultiplier(multiplier: 0.0001)
            }
        }
        
        resultSummary.register(CustomSummaryResultCellView.self, forCellReuseIdentifier: "popupRowCell")
        
        if let resultTitleTxt = resultTitleTxt {
            resultTitle.text = resultTitleTxt
        }
        
        if let resultMsgTxt = resultMsgTxt {
            resultMsg.text = resultMsgTxt
            //resultMsg.font = UIFont.systemFont(ofSize: 20.0)
        }
        
        if let repeatButtonTxt = repeatButtonTxt {
            repeatButton.setTitle(repeatButtonTxt, for: .normal)
            repeatButton.adjustFont(scale: 3.0)
        }
        
        if (success) {
            resultImg.loadGif(name: "success")
        } else {
            let failed = UIImage(named: "failed_icon")
            resultImg.image = failed
        }
        
        resultSummary.tableFooterView = UIView()
        resultSummary.backgroundColor = UIColor(named: "colorPrimaryDark")
        resultSummary.dataSource = self
        resultSummary.delegate = self
        resultSummary.isScrollEnabled = true
        resultSummary.reloadData()
        
        if let fragmentSection = self.fragmentSection {
            parentController?.refreshHeader(fragmentSection: fragmentSection)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let summaryValues = summaryValues else {
            return 0
        }
        return summaryValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("item row \(indexPath.row)")
        let cell : CustomSummaryResultCellView = self.resultSummary.dequeueReusableCell(withIdentifier: "popupRowCell") as! CustomSummaryResultCellView
        cell.backgroundColor = UIColor(named: "colorPrimaryDark")
        
        guard let summaryValues = summaryValues else {
            return cell
        }
        let item:SummaryItem = summaryValues[indexPath.row]
        print("item name \(item.name)")
        print("item value \(item.value)")
        
        cell.fieldName.numberOfLines = 0
        cell.fieldName.text = item.name
        cell.fieldName.textColor = UIColor(named: "textSectionColor")
        cell.fieldName.font = UIFont.boldSystemFont(ofSize: 14.0)
        cell.fieldValue.sizeToFit()
        
        cell.fieldValue.numberOfLines = 0
        cell.fieldValue.text = item.value
        cell.fieldValue.textColor = UIColor(named: "textSectionColor")
        cell.fieldValue.font = UIFont.systemFont(ofSize: 14.0)
        cell.fieldValue.sizeToFit()
        
        cell.setWidthPercentages(widhtp1: 0.4, widhtp2: 0.6)
        cell.fieldValue.textAlignment = .right
    
        cell.layoutIfNeeded()
    
    
        return cell
    }
    

    @IBAction func repeatOperation(_ sender: Any) {
        if let fragmentSection = self.fragmentSection {
            let targetAction = fragmentSection.rawValue
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let target = storyboard.instantiateViewController(withIdentifier: targetAction) as! SICobroViewController
            parentController?.onSectionChange(target: target, fragmentSection: fragmentSection)
        }
    }
    
    @IBAction func performPostAction(_ sender: Any) {
        if let postOperationAction = self.postOperationAction {
            postOperationAction.postAction(abstractResultViewController: self)
        }
    }
    
    func convert<T: AbstractResultViewController>(to _: T.Type) {
        object_setClass(self, T.self)
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

/*
 *
 */
public class SummaryItem {
    var name:String
    var value:String
    
    init(name:String, value:String) {
        self.name = name
        self.value = value
    }
}
/*
 *
 */
protocol SaveResultHandler {
    func saveResult() -> Bool
}
