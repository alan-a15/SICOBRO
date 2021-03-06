//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class LoginRequest: APIModel {

    public var deviceBrand: String?

    public var deviceId: String?

    public var deviceModel: String?

    public var deviceOSVersion: String?

    public var redId: String?

    public var storePassword: String?

    public var storeUsername: String?

    public init(deviceBrand: String? = nil, deviceId: String? = nil, deviceModel: String? = nil, deviceOSVersion: String? = nil, redId: String? = nil, storePassword: String? = nil, storeUsername: String? = nil) {
        self.deviceBrand = deviceBrand
        self.deviceId = deviceId
        self.deviceModel = deviceModel
        self.deviceOSVersion = deviceOSVersion
        self.redId = redId
        self.storePassword = storePassword
        self.storeUsername = storeUsername
    }

    private enum CodingKeys: String, CodingKey {
        case deviceBrand
        case deviceId
        case deviceModel
        case deviceOSVersion
        case redId
        case storePassword
        case storeUsername
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        deviceBrand = try container.decodeIfPresent(.deviceBrand)
        deviceId = try container.decodeIfPresent(.deviceId)
        deviceModel = try container.decodeIfPresent(.deviceModel)
        deviceOSVersion = try container.decodeIfPresent(.deviceOSVersion)
        redId = try container.decodeIfPresent(.redId)
        storePassword = try container.decodeIfPresent(.storePassword)
        storeUsername = try container.decodeIfPresent(.storeUsername)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(deviceBrand, forKey: .deviceBrand)
        try container.encodeIfPresent(deviceId, forKey: .deviceId)
        try container.encodeIfPresent(deviceModel, forKey: .deviceModel)
        try container.encodeIfPresent(deviceOSVersion, forKey: .deviceOSVersion)
        try container.encodeIfPresent(redId, forKey: .redId)
        try container.encodeIfPresent(storePassword, forKey: .storePassword)
        try container.encodeIfPresent(storeUsername, forKey: .storeUsername)
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? LoginRequest else { return false }
      guard self.deviceBrand == object.deviceBrand else { return false }
      guard self.deviceId == object.deviceId else { return false }
      guard self.deviceModel == object.deviceModel else { return false }
      guard self.deviceOSVersion == object.deviceOSVersion else { return false }
      guard self.redId == object.redId else { return false }
      guard self.storePassword == object.storePassword else { return false }
      guard self.storeUsername == object.storeUsername else { return false }
      return true
    }

    public static func == (lhs: LoginRequest, rhs: LoginRequest) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}
