//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class CustomerBalanceDto: APIModel {

    public enum ProductType: String, Codable {
        case tae = "TAE"
        case servicePayment = "SERVICE_PAYMENT"

        public static let cases: [ProductType] = [
          .tae,
          .servicePayment,
        ]
    }

    public var balance: Int?

    public var balanceLabel: String?

    public var customerId: Int?

    public var id: Int?

    public var name: String?

    public var productType: ProductType?

    public var productTypeLabel: String?

    public var storeId: Int?

    public var storeIdLabel: String?

    public var storeName: String?

    public init(balance: Int? = nil, balanceLabel: String? = nil, customerId: Int? = nil, id: Int? = nil, name: String? = nil, productType: ProductType? = nil, productTypeLabel: String? = nil, storeId: Int? = nil, storeIdLabel: String? = nil, storeName: String? = nil) {
        self.balance = balance
        self.balanceLabel = balanceLabel
        self.customerId = customerId
        self.id = id
        self.name = name
        self.productType = productType
        self.productTypeLabel = productTypeLabel
        self.storeId = storeId
        self.storeIdLabel = storeIdLabel
        self.storeName = storeName
    }

    private enum CodingKeys: String, CodingKey {
        case balance
        case balanceLabel
        case customerId
        case id
        case name
        case productType
        case productTypeLabel
        case storeId
        case storeIdLabel
        case storeName
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        balance = try container.decodeIfPresent(.balance)
        balanceLabel = try container.decodeIfPresent(.balanceLabel)
        customerId = try container.decodeIfPresent(.customerId)
        id = try container.decodeIfPresent(.id)
        name = try container.decodeIfPresent(.name)
        productType = try container.decodeIfPresent(.productType)
        productTypeLabel = try container.decodeIfPresent(.productTypeLabel)
        storeId = try container.decodeIfPresent(.storeId)
        storeIdLabel = try container.decodeIfPresent(.storeIdLabel)
        storeName = try container.decodeIfPresent(.storeName)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(balance, forKey: .balance)
        try container.encodeIfPresent(balanceLabel, forKey: .balanceLabel)
        try container.encodeIfPresent(customerId, forKey: .customerId)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(productType, forKey: .productType)
        try container.encodeIfPresent(productTypeLabel, forKey: .productTypeLabel)
        try container.encodeIfPresent(storeId, forKey: .storeId)
        try container.encodeIfPresent(storeIdLabel, forKey: .storeIdLabel)
        try container.encodeIfPresent(storeName, forKey: .storeName)
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? CustomerBalanceDto else { return false }
      guard self.balance == object.balance else { return false }
      guard self.balanceLabel == object.balanceLabel else { return false }
      guard self.customerId == object.customerId else { return false }
      guard self.id == object.id else { return false }
      guard self.name == object.name else { return false }
      guard self.productType == object.productType else { return false }
      guard self.productTypeLabel == object.productTypeLabel else { return false }
      guard self.storeId == object.storeId else { return false }
      guard self.storeIdLabel == object.storeIdLabel else { return false }
      guard self.storeName == object.storeName else { return false }
      return true
    }

    public static func == (lhs: CustomerBalanceDto, rhs: CustomerBalanceDto) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
