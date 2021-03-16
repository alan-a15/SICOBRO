//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class PasswordValidationResponse: APIModel {

    public enum ActionRequired: String, Codable {
        case none = "NONE"
        case changePassword = "CHANGE_PASSWORD"
        case usePasswordEmailed = "USE_PASSWORD_EMAILED"

        public static let cases: [ActionRequired] = [
          .none,
          .changePassword,
          .usePasswordEmailed,
        ]
    }

    public var actionRequired: ActionRequired?

    public init(actionRequired: ActionRequired? = nil) {
        self.actionRequired = actionRequired
    }

    private enum CodingKeys: String, CodingKey {
        case actionRequired
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        actionRequired = try container.decodeIfPresent(.actionRequired)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(actionRequired, forKey: .actionRequired)
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? PasswordValidationResponse else { return false }
      guard self.actionRequired == object.actionRequired else { return false }
      return true
    }

    public static func == (lhs: PasswordValidationResponse, rhs: PasswordValidationResponse) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}