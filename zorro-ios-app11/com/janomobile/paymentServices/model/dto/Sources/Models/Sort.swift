//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class Sort: APIModel {

    public var empty: Bool?

    public var sorted: Bool?

    public var unsorted: Bool?

    public init(empty: Bool? = nil, sorted: Bool? = nil, unsorted: Bool? = nil) {
        self.empty = empty
        self.sorted = sorted
        self.unsorted = unsorted
    }

    private enum CodingKeys: String, CodingKey {
        case empty
        case sorted
        case unsorted
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        empty = try container.decodeIfPresent(.empty)
        sorted = try container.decodeIfPresent(.sorted)
        unsorted = try container.decodeIfPresent(.unsorted)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(empty, forKey: .empty)
        try container.encodeIfPresent(sorted, forKey: .sorted)
        try container.encodeIfPresent(unsorted, forKey: .unsorted)
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? Sort else { return false }
      guard self.empty == object.empty else { return false }
      guard self.sorted == object.sorted else { return false }
      guard self.unsorted == object.unsorted else { return false }
      return true
    }

    public static func == (lhs: Sort, rhs: Sort) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
