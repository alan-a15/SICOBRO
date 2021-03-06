//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class VoidTxnRequest: APIModel {

    public var remarks: String?

    public var retrievalId: String?

    public init(remarks: String? = nil, retrievalId: String? = nil) {
        self.remarks = remarks
        self.retrievalId = retrievalId
    }

    private enum CodingKeys: String, CodingKey {
        case remarks
        case retrievalId
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        remarks = try container.decodeIfPresent(.remarks)
        retrievalId = try container.decodeIfPresent(.retrievalId)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(remarks, forKey: .remarks)
        try container.encodeIfPresent(retrievalId, forKey: .retrievalId)
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? VoidTxnRequest else { return false }
      guard self.remarks == object.remarks else { return false }
      guard self.retrievalId == object.retrievalId else { return false }
      return true
    }

    public static func == (lhs: VoidTxnRequest, rhs: VoidTxnRequest) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
