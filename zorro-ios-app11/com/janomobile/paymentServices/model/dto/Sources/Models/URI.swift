//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

public class URI: APIModel {

    public var absolute: Bool?

    public var authority: String?

    public var fragment: String?

    public var host: String?

    public var opaque: Bool?

    public var path: String?

    public var port: Int?

    public var query: String?

    public var rawAuthority: String?

    public var rawFragment: String?

    public var rawPath: String?

    public var rawQuery: String?

    public var rawSchemeSpecificPart: String?

    public var rawUserInfo: String?

    public var scheme: String?

    public var schemeSpecificPart: String?

    public var userInfo: String?

    public init(absolute: Bool? = nil, authority: String? = nil, fragment: String? = nil, host: String? = nil, opaque: Bool? = nil, path: String? = nil, port: Int? = nil, query: String? = nil, rawAuthority: String? = nil, rawFragment: String? = nil, rawPath: String? = nil, rawQuery: String? = nil, rawSchemeSpecificPart: String? = nil, rawUserInfo: String? = nil, scheme: String? = nil, schemeSpecificPart: String? = nil, userInfo: String? = nil) {
        self.absolute = absolute
        self.authority = authority
        self.fragment = fragment
        self.host = host
        self.opaque = opaque
        self.path = path
        self.port = port
        self.query = query
        self.rawAuthority = rawAuthority
        self.rawFragment = rawFragment
        self.rawPath = rawPath
        self.rawQuery = rawQuery
        self.rawSchemeSpecificPart = rawSchemeSpecificPart
        self.rawUserInfo = rawUserInfo
        self.scheme = scheme
        self.schemeSpecificPart = schemeSpecificPart
        self.userInfo = userInfo
    }

    private enum CodingKeys: String, CodingKey {
        case absolute
        case authority
        case fragment
        case host
        case opaque
        case path
        case port
        case query
        case rawAuthority
        case rawFragment
        case rawPath
        case rawQuery
        case rawSchemeSpecificPart
        case rawUserInfo
        case scheme
        case schemeSpecificPart
        case userInfo
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        absolute = try container.decodeIfPresent(.absolute)
        authority = try container.decodeIfPresent(.authority)
        fragment = try container.decodeIfPresent(.fragment)
        host = try container.decodeIfPresent(.host)
        opaque = try container.decodeIfPresent(.opaque)
        path = try container.decodeIfPresent(.path)
        port = try container.decodeIfPresent(.port)
        query = try container.decodeIfPresent(.query)
        rawAuthority = try container.decodeIfPresent(.rawAuthority)
        rawFragment = try container.decodeIfPresent(.rawFragment)
        rawPath = try container.decodeIfPresent(.rawPath)
        rawQuery = try container.decodeIfPresent(.rawQuery)
        rawSchemeSpecificPart = try container.decodeIfPresent(.rawSchemeSpecificPart)
        rawUserInfo = try container.decodeIfPresent(.rawUserInfo)
        scheme = try container.decodeIfPresent(.scheme)
        schemeSpecificPart = try container.decodeIfPresent(.schemeSpecificPart)
        userInfo = try container.decodeIfPresent(.userInfo)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(absolute, forKey: .absolute)
        try container.encodeIfPresent(authority, forKey: .authority)
        try container.encodeIfPresent(fragment, forKey: .fragment)
        try container.encodeIfPresent(host, forKey: .host)
        try container.encodeIfPresent(opaque, forKey: .opaque)
        try container.encodeIfPresent(path, forKey: .path)
        try container.encodeIfPresent(port, forKey: .port)
        try container.encodeIfPresent(query, forKey: .query)
        try container.encodeIfPresent(rawAuthority, forKey: .rawAuthority)
        try container.encodeIfPresent(rawFragment, forKey: .rawFragment)
        try container.encodeIfPresent(rawPath, forKey: .rawPath)
        try container.encodeIfPresent(rawQuery, forKey: .rawQuery)
        try container.encodeIfPresent(rawSchemeSpecificPart, forKey: .rawSchemeSpecificPart)
        try container.encodeIfPresent(rawUserInfo, forKey: .rawUserInfo)
        try container.encodeIfPresent(scheme, forKey: .scheme)
        try container.encodeIfPresent(schemeSpecificPart, forKey: .schemeSpecificPart)
        try container.encodeIfPresent(userInfo, forKey: .userInfo)
    }

    public func isEqual(to object: Any?) -> Bool {
      guard let object = object as? URI else { return false }
      guard self.absolute == object.absolute else { return false }
      guard self.authority == object.authority else { return false }
      guard self.fragment == object.fragment else { return false }
      guard self.host == object.host else { return false }
      guard self.opaque == object.opaque else { return false }
      guard self.path == object.path else { return false }
      guard self.port == object.port else { return false }
      guard self.query == object.query else { return false }
      guard self.rawAuthority == object.rawAuthority else { return false }
      guard self.rawFragment == object.rawFragment else { return false }
      guard self.rawPath == object.rawPath else { return false }
      guard self.rawQuery == object.rawQuery else { return false }
      guard self.rawSchemeSpecificPart == object.rawSchemeSpecificPart else { return false }
      guard self.rawUserInfo == object.rawUserInfo else { return false }
      guard self.scheme == object.scheme else { return false }
      guard self.schemeSpecificPart == object.schemeSpecificPart else { return false }
      guard self.userInfo == object.userInfo else { return false }
      return true
    }

    public static func == (lhs: URI, rhs: URI) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}