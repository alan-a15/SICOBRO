//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class ReportBillpocketTxn: APIModel {

    public var accountType: String?

    public var aid: String?

    public var amount: String?

    public var amountCents: Int?

    public var appError: String?

    public var applabel: String?

    public var arqc: String?

    public var authorizationNumber: String?

    public var bank: String?

    public var captureMode: String?

    public var cardtype: String?

    public var creditcard: String?

    public var customerId: Int?

    public var deviceToken: String?

    public var email: String?

    public var hidePrinter: Bool?

    public var id: Int?

    public var identifier: String?

    public var janoReference: String?

    public var mandatoryPhoto: Bool?

    public var mobileSessionId: Int?

    public var msi: String?

    public var phone: String?

    public var reference: String?

    public var result: String?

    public var skipMailPrint: Bool?

    public var statusinfo: String?

    public var storeId: Int?

    public var thirdPartyId: String?

    public var tip: String?

    public var transactionId: String?

    public var txnDateId: Int?

    public var txnLocalDateTime: DateTime?

    public var url: String?

    public var urlScheme: String?

    public var userToken: String?

    public var xpLandscape: Bool?

    public init(accountType: String? = nil, aid: String? = nil, amount: String? = nil, amountCents: Int? = nil, appError: String? = nil, applabel: String? = nil, arqc: String? = nil, authorizationNumber: String? = nil, bank: String? = nil, captureMode: String? = nil, cardtype: String? = nil, creditcard: String? = nil, customerId: Int? = nil, deviceToken: String? = nil, email: String? = nil, hidePrinter: Bool? = nil, id: Int? = nil, identifier: String? = nil, janoReference: String? = nil, mandatoryPhoto: Bool? = nil, mobileSessionId: Int? = nil, msi: String? = nil, phone: String? = nil, reference: String? = nil, result: String? = nil, skipMailPrint: Bool? = nil, statusinfo: String? = nil, storeId: Int? = nil, thirdPartyId: String? = nil, tip: String? = nil, transactionId: String? = nil, txnDateId: Int? = nil, txnLocalDateTime: DateTime? = nil, url: String? = nil, urlScheme: String? = nil, userToken: String? = nil, xpLandscape: Bool? = nil) {
        self.accountType = accountType
        self.aid = aid
        self.amount = amount
        self.amountCents = amountCents
        self.appError = appError
        self.applabel = applabel
        self.arqc = arqc
        self.authorizationNumber = authorizationNumber
        self.bank = bank
        self.captureMode = captureMode
        self.cardtype = cardtype
        self.creditcard = creditcard
        self.customerId = customerId
        self.deviceToken = deviceToken
        self.email = email
        self.hidePrinter = hidePrinter
        self.id = id
        self.identifier = identifier
        self.janoReference = janoReference
        self.mandatoryPhoto = mandatoryPhoto
        self.mobileSessionId = mobileSessionId
        self.msi = msi
        self.phone = phone
        self.reference = reference
        self.result = result
        self.skipMailPrint = skipMailPrint
        self.statusinfo = statusinfo
        self.storeId = storeId
        self.thirdPartyId = thirdPartyId
        self.tip = tip
        self.transactionId = transactionId
        self.txnDateId = txnDateId
        self.txnLocalDateTime = txnLocalDateTime
        self.url = url
        self.urlScheme = urlScheme
        self.userToken = userToken
        self.xpLandscape = xpLandscape
    }

    private enum CodingKeys: String, CodingKey {
        case accountType
        case aid
        case amount
        case amountCents
        case appError
        case applabel
        case arqc
        case authorizationNumber
        case bank
        case captureMode
        case cardtype
        case creditcard
        case customerId
        case deviceToken
        case email
        case hidePrinter
        case id
        case identifier
        case janoReference
        case mandatoryPhoto
        case mobileSessionId
        case msi
        case phone
        case reference
        case result
        case skipMailPrint
        case statusinfo
        case storeId
        case thirdPartyId
        case tip
        case transactionId
        case txnDateId
        case txnLocalDateTime
        case url
        case urlScheme
        case userToken
        case xpLandscape
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        accountType = try container.decodeIfPresent(.accountType)
        aid = try container.decodeIfPresent(.aid)
        amount = try container.decodeIfPresent(.amount)
        amountCents = try container.decodeIfPresent(.amountCents)
        appError = try container.decodeIfPresent(.appError)
        applabel = try container.decodeIfPresent(.applabel)
        arqc = try container.decodeIfPresent(.arqc)
        authorizationNumber = try container.decodeIfPresent(.authorizationNumber)
        bank = try container.decodeIfPresent(.bank)
        captureMode = try container.decodeIfPresent(.captureMode)
        cardtype = try container.decodeIfPresent(.cardtype)
        creditcard = try container.decodeIfPresent(.creditcard)
        customerId = try container.decodeIfPresent(.customerId)
        deviceToken = try container.decodeIfPresent(.deviceToken)
        email = try container.decodeIfPresent(.email)
        hidePrinter = try container.decodeIfPresent(.hidePrinter)
        id = try container.decodeIfPresent(.id)
        identifier = try container.decodeIfPresent(.identifier)
        janoReference = try container.decodeIfPresent(.janoReference)
        mandatoryPhoto = try container.decodeIfPresent(.mandatoryPhoto)
        mobileSessionId = try container.decodeIfPresent(.mobileSessionId)
        msi = try container.decodeIfPresent(.msi)
        phone = try container.decodeIfPresent(.phone)
        reference = try container.decodeIfPresent(.reference)
        result = try container.decodeIfPresent(.result)
        skipMailPrint = try container.decodeIfPresent(.skipMailPrint)
        statusinfo = try container.decodeIfPresent(.statusinfo)
        storeId = try container.decodeIfPresent(.storeId)
        thirdPartyId = try container.decodeIfPresent(.thirdPartyId)
        tip = try container.decodeIfPresent(.tip)
        transactionId = try container.decodeIfPresent(.transactionId)
        txnDateId = try container.decodeIfPresent(.txnDateId)
        txnLocalDateTime = try container.decodeIfPresent(.txnLocalDateTime)
        url = try container.decodeIfPresent(.url)
        urlScheme = try container.decodeIfPresent(.urlScheme)
        userToken = try container.decodeIfPresent(.userToken)
        xpLandscape = try container.decodeIfPresent(.xpLandscape)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(accountType, forKey: .accountType)
        try container.encodeIfPresent(aid, forKey: .aid)
        try container.encodeIfPresent(amount, forKey: .amount)
        try container.encodeIfPresent(amountCents, forKey: .amountCents)
        try container.encodeIfPresent(appError, forKey: .appError)
        try container.encodeIfPresent(applabel, forKey: .applabel)
        try container.encodeIfPresent(arqc, forKey: .arqc)
        try container.encodeIfPresent(authorizationNumber, forKey: .authorizationNumber)
        try container.encodeIfPresent(bank, forKey: .bank)
        try container.encodeIfPresent(captureMode, forKey: .captureMode)
        try container.encodeIfPresent(cardtype, forKey: .cardtype)
        try container.encodeIfPresent(creditcard, forKey: .creditcard)
        try container.encodeIfPresent(customerId, forKey: .customerId)
        try container.encodeIfPresent(deviceToken, forKey: .deviceToken)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(hidePrinter, forKey: .hidePrinter)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(identifier, forKey: .identifier)
        try container.encodeIfPresent(janoReference, forKey: .janoReference)
        try container.encodeIfPresent(mandatoryPhoto, forKey: .mandatoryPhoto)
        try container.encodeIfPresent(mobileSessionId, forKey: .mobileSessionId)
        try container.encodeIfPresent(msi, forKey: .msi)
        try container.encodeIfPresent(phone, forKey: .phone)
        try container.encodeIfPresent(reference, forKey: .reference)
        try container.encodeIfPresent(result, forKey: .result)
        try container.encodeIfPresent(skipMailPrint, forKey: .skipMailPrint)
        try container.encodeIfPresent(statusinfo, forKey: .statusinfo)
        try container.encodeIfPresent(storeId, forKey: .storeId)
        try container.encodeIfPresent(thirdPartyId, forKey: .thirdPartyId)
        try container.encodeIfPresent(tip, forKey: .tip)
        try container.encodeIfPresent(transactionId, forKey: .transactionId)
        try container.encodeIfPresent(txnDateId, forKey: .txnDateId)
        try container.encodeIfPresent(txnLocalDateTime, forKey: .txnLocalDateTime)
        try container.encodeIfPresent(url, forKey: .url)
        try container.encodeIfPresent(urlScheme, forKey: .urlScheme)
        try container.encodeIfPresent(userToken, forKey: .userToken)
        try container.encodeIfPresent(xpLandscape, forKey: .xpLandscape)
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? ReportBillpocketTxn else { return false }
      guard self.accountType == object.accountType else { return false }
      guard self.aid == object.aid else { return false }
      guard self.amount == object.amount else { return false }
      guard self.amountCents == object.amountCents else { return false }
      guard self.appError == object.appError else { return false }
      guard self.applabel == object.applabel else { return false }
      guard self.arqc == object.arqc else { return false }
      guard self.authorizationNumber == object.authorizationNumber else { return false }
      guard self.bank == object.bank else { return false }
      guard self.captureMode == object.captureMode else { return false }
      guard self.cardtype == object.cardtype else { return false }
      guard self.creditcard == object.creditcard else { return false }
      guard self.customerId == object.customerId else { return false }
      guard self.deviceToken == object.deviceToken else { return false }
      guard self.email == object.email else { return false }
      guard self.hidePrinter == object.hidePrinter else { return false }
      guard self.id == object.id else { return false }
      guard self.identifier == object.identifier else { return false }
      guard self.janoReference == object.janoReference else { return false }
      guard self.mandatoryPhoto == object.mandatoryPhoto else { return false }
      guard self.mobileSessionId == object.mobileSessionId else { return false }
      guard self.msi == object.msi else { return false }
      guard self.phone == object.phone else { return false }
      guard self.reference == object.reference else { return false }
      guard self.result == object.result else { return false }
      guard self.skipMailPrint == object.skipMailPrint else { return false }
      guard self.statusinfo == object.statusinfo else { return false }
      guard self.storeId == object.storeId else { return false }
      guard self.thirdPartyId == object.thirdPartyId else { return false }
      guard self.tip == object.tip else { return false }
      guard self.transactionId == object.transactionId else { return false }
      guard self.txnDateId == object.txnDateId else { return false }
      guard self.txnLocalDateTime == object.txnLocalDateTime else { return false }
      guard self.url == object.url else { return false }
      guard self.urlScheme == object.urlScheme else { return false }
      guard self.userToken == object.userToken else { return false }
      guard self.xpLandscape == object.xpLandscape else { return false }
      return true
    }

    public static func == (lhs: ReportBillpocketTxn, rhs: ReportBillpocketTxn) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
