//
// Generated by SwagGen
// https://github.com/yonaskolb/SwagGen
//

import Foundation

extension JanoPaymentservicesAPI.Transacciones {

    /**
    sendCustomerReceipt
    */
    public enum SendCustomerReceiptUsingPOST {

        public static let service = APIService<Response>(id: "sendCustomerReceiptUsingPOST", tag: "Transacciones", method: "POST", path: "/api/servicepayment/send-customer-receipt", hasBody: true)

        public final class Request: APIRequest<Response> {

            public struct Options {

                /** App Version */
                public var appversion: String?

                /** Device ID */
                public var deviceid: String?

                /** Session Token */
                public var sessiontoken: String?

                public init(appversion: String? = nil, deviceid: String? = nil, sessiontoken: String? = nil) {
                    self.appversion = appversion
                    self.deviceid = deviceid
                    self.sessiontoken = sessiontoken
                }
            }

            public var options: Options

            public var customerReceiptRequest: CustomerReceiptRequest

            public init(customerReceiptRequest: CustomerReceiptRequest, options: Options) {
                self.customerReceiptRequest = customerReceiptRequest
                self.options = options
                super.init(service: SendCustomerReceiptUsingPOST.service) {
                    let jsonEncoder = JSONEncoder()
                    return try jsonEncoder.encode(customerReceiptRequest)
                }
            }

            /// convenience initialiser so an Option doesn't have to be created
            public convenience init(appversion: String? = nil, customerReceiptRequest: CustomerReceiptRequest, deviceid: String? = nil, sessiontoken: String? = nil) {
                let options = Options(appversion: appversion, deviceid: deviceid, sessiontoken: sessiontoken)
                self.init(customerReceiptRequest: customerReceiptRequest, options: options)
            }
        }

        public enum Response: APIResponseValue, CustomStringConvertible, CustomDebugStringConvertible {
            public typealias SuccessType = Void

            /** OK */
            case status200

            /** Created */
            case status201

            /** Unauthorized */
            case status401

            /** Forbidden */
            case status403

            /** Not Found */
            case status404

            public var success: Void? {
                switch self {
                case .status200: return ()
                case .status201: return ()
                default: return nil
                }
            }

            public var response: Any {
                switch self {
                default: return ()
                }
            }

            public var statusCode: Int {
                switch self {
                case .status200: return 200
                case .status201: return 201
                case .status401: return 401
                case .status403: return 403
                case .status404: return 404
                }
            }

            public var successful: Bool {
                switch self {
                case .status200: return true
                case .status201: return true
                case .status401: return false
                case .status403: return false
                case .status404: return false
                }
            }

            public init(statusCode: Int, data: Data, decoder: ResponseDecoder) throws {
                switch statusCode {
                case 200: self = .status200
                case 201: self = .status201
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
