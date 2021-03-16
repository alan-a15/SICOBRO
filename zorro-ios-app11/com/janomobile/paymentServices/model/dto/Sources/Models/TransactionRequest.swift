//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class TransactionRequest: APIModel {

    public var amountDecimal: String?

    public var clientUUID: String?

    public var clientVersion: String?

    public var janoUUID: String?

    public var paymentReference: String?

    public var productTxnId: String?

    public init(amountDecimal: String? = nil, clientUUID: String? = nil, clientVersion: String? = nil, janoUUID: String? = nil, paymentReference: String? = nil, productTxnId: String? = nil) {
        self.amountDecimal = amountDecimal
        self.clientUUID = clientUUID
        self.clientVersion = clientVersion
        self.janoUUID = janoUUID
        self.paymentReference = paymentReference
        self.productTxnId = productTxnId
    }

    private enum CodingKeys: String, CodingKey {
        case amountDecimal
        case clientUUID
        case clientVersion
        case janoUUID
        case paymentReference
        case productTxnId
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        amountDecimal = try container.decodeIfPresent(.amountDecimal)
        clientUUID = try container.decodeIfPresent(.clientUUID)
        clientVersion = try container.decodeIfPresent(.clientVersion)
        janoUUID = try container.decodeIfPresent(.janoUUID)
        paymentReference = try container.decodeIfPresent(.paymentReference)
        productTxnId = try container.decodeIfPresent(.productTxnId)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(amountDecimal, forKey: .amountDecimal)
        try container.encodeIfPresent(clientUUID, forKey: .clientUUID)
        try container.encodeIfPresent(clientVersion, forKey: .clientVersion)
        try container.encodeIfPresent(janoUUID, forKey: .janoUUID)
        try container.encodeIfPresent(paymentReference, forKey: .paymentReference)
        try container.encodeIfPresent(productTxnId, forKey: .productTxnId)
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? TransactionRequest else { return false }
      guard self.amountDecimal == object.amountDecimal else { return false }
      guard self.clientUUID == object.clientUUID else { return false }
      guard self.clientVersion == object.clientVersion else { return false }
      guard self.janoUUID == object.janoUUID else { return false }
      guard self.paymentReference == object.paymentReference else { return false }
      guard self.productTxnId == object.productTxnId else { return false }
      return true
    }

    public static func == (lhs: TransactionRequest, rhs: TransactionRequest) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
