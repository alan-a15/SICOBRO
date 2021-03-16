//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class ChangePasswordRequest: APIModel {

    public var password: String?

    public init(password: String? = nil) {
        self.password = password
    }

    private enum CodingKeys: String, CodingKey {
        case password
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        password = try container.decodeIfPresent(.password)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(password, forKey: .password)
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? ChangePasswordRequest else { return false }
      guard self.password == object.password else { return false }
      return true
    }

    public static func == (lhs: ChangePasswordRequest, rhs: ChangePasswordRequest) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
