//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

extension JanoAPI.ConsultaVentas {

    /**
    Get File with id , id=file id returned for reporting method , returns file as stream
    */
    public enum DailyReportUsingGET {

        public static let service = APIService<Response>(id: "dailyReportUsingGET", tag: "ConsultaVentas", method: "GET", path: "/api/sales/reports/file/{fileId}", hasBody: false)

        public final class Request: APIRequest<Response> {

            public struct Options {

                /** App Version */
                public var appversion: String?

                /** Device ID */
                public var deviceid: String?

                /** fileId */
                public var fileId: String

                /** Session Token */
                public var sessiontoken: String?

                public init(appversion: String? = nil, deviceid: String? = nil, fileId: String, sessiontoken: String? = nil) {
                    self.appversion = appversion
                    self.deviceid = deviceid
                    self.fileId = fileId
                    self.sessiontoken = sessiontoken
                }
            }

            public var options: Options

            public init(options: Options) {
                self.options = options
                super.init(service: DailyReportUsingGET.service)
            }

            /// convenience initialiser so an Option doesn't have to be created
            public convenience init(appversion: String? = nil, deviceid: String? = nil, fileId: String, sessiontoken: String? = nil) {
                let options = Options(appversion: appversion, deviceid: deviceid, fileId: fileId, sessiontoken: sessiontoken)
                self.init(options: options)
            }

            public override var path: String {
                return super.path.replacingOccurrences(of: "{" + "fileId" + "}", with: "\(self.options.fileId)")
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {
            public typealias SuccessType = Resource

            /** OK */
            case status200(Resource)

            /** Unauthorized */
            case status401

            /** Forbidden */
            case status403

            /** Not Found */
            case status404

            public var success: Resource? {
                switch self {
                case .status200(let response): return response
                default: return nil
                }
            }

            public var response: Any {
                switch self {
                case .status200(let response): return response
                default: return ()
                }
            }

            public var statusCode: Int {
                switch self {
                case .status200: return 200
                case .status401: return 401
                case .status403: return 403
                case .status404: return 404
                }
            }

            public var successful: Bool {
                switch self {
                case .status200: return true
                case .status401: return false
                case .status403: return false
                case .status404: return false
                }
            }

            public init(statusCode: Int, data: Data, decoder: ResponseDecoder) throws {
                switch statusCode {
                case 200: self = try .status200(decoder.decode(Resource.self, from: data))
                case 401: self = .status401
                case 403: self = .status403
                case 404: self = .status404
                default: throw APIClientError.unexpectedStatusCode(statusCode: statusCode, data: data)
                }
            }

            public var description: String {
                return "\(statusCode) \(successful ? "success" : "failure")"
            }

            public var debugDescription: String {
                var string = description
                let responseString = "\(response)"
                if responseString != "()" {
                    string += "\n\(responseString)"
                }
                return string
            }
        }
    }
}