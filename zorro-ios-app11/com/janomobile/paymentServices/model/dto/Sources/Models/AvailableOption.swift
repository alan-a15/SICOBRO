//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class AvailableOption: APIModel {

    public var key: String?

    public var name: String?

    public init(key: String? = nil, name: String? = nil) {
        self.key = key
        self.name = name
    }

    private enum CodingKeys: String, CodingKey {
        case key
        case name
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        key = try container.decodeIfPresent(.key)
        name = try container.decodeIfPresent(.name)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(key, forKey: .key)
        try container.encodeIfPresent(name, forKey: .name)
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? AvailableOption else { return false }
      guard self.key == object.key else { return false }
      guard self.name == object.name else { return false }
      return true
    }

    public static func == (lhs: AvailableOption, rhs: AvailableOption) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}