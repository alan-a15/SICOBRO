//
//  TransactionResponseObj.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 19/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Foundation

public class TransactionResponseObj : TransactionResponse {

    var success : Bool = false
    var tipoError : String = ""
    var msgError : String = ""
    var clientUUID: String = ""
    var janoUUID: String = ""

    func fromTransactionResponse(transactionResponse : TransactionResponse) {
        self.janoRetrievalId = transactionResponse.janoRetrievalId
        self.approvalCode = transactionResponse.approvalCode
        self.paymentReference = transactionResponse.paymentReference
        self.productName = transactionResponse.productName
        self.productTxnId = transactionResponse.productTxnId
        self.newBalance = transactionResponse.newBalance
        self.commission = transactionResponse.commission
        self.balanceDecrease = transactionResponse.balanceDecrease
        self.amount = transactionResponse.amount
        self.totalAmount = transactionResponse.totalAmount
    }

}
