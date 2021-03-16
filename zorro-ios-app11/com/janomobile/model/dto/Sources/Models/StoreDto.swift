//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class StoreDto: APIModel {

    public enum Status: String, Codable {
        case active = "ACTIVE"
        case inactive = "INACTIVE"

        public static let cases: [Status] = [
          .active,
          .inactive,
        ]
    }

    public var customerId: Int?

    public var id: Int?

    public var name: String?

    public var status: Status?

    public var statusLabel: String?

    public var storeId: String?

    public init(customerId: Int? = nil, id: Int? = nil, name: String? = nil, status: Status? = nil, statusLabel: String? = nil, storeId: String? = nil) {
        self.customerId = customerId
        self.id = id
        self.name = name
        self.status = status
        self.statusLabel = statusLabel
        self.storeId = storeId
    }

    private enum CodingKeys: String, CodingKey {
        case customerId
        case id
        case name
        case status
        case statusLabel
        case storeId
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        customerId = try container.decodeIfPresent(.customerId)
        id = try container.decodeIfPresent(.id)
        name = try container.decodeIfPresent(.name)
        status = try container.decodeIfPresent(.status)
        statusLabel = try container.decodeIfPresent(.statusLabel)
        storeId = try container.decodeIfPresent(.storeId)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(customerId, forKey: .customerId)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(statusLabel, forKey: .statusLabel)
        try container.encodeIfPresent(storeId, forKey: .storeId)
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? StoreDto else { return false }
      guard self.customerId == object.customerId else { return false }
      guard self.id == object.id else { return false }
      guard self.name == object.name else { return false }
      guard self.status == object.status else { return false }
      guard self.statusLabel == object.statusLabel else { return false }
      guard self.storeId == object.storeId else { return false }
      return true
    }

    public static func == (lhs: StoreDto, rhs: StoreDto) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}