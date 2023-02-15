//
//  DeviceCheckServerless.swift
//  DeviceCheckServerless
//
//  Created by Denis Karpenko on 15.02.2023.
//

import Foundation
import DeviceCheck

public class DeviceCheck {
    
    public enum CheckError: Error {
        case wrongFormat
    }
    
    public struct Bits {
        let bit0: Bool
        let bit1: Bool
    }

    private let urlSession: URLSession = URLSession.shared
    private let requestBuilder: RequestBuilder
    
    public init(p8: String, keyId: String, teamId: String, developmentAPI: Bool = false) {
        self.requestBuilder = RequestBuilder(p8: p8, keyId: keyId, teamId: teamId, developmentAPI: developmentAPI)
    }
    
    public func update(bits: Bits) async throws {
        let tokenData = try await DCDevice.current.generateToken()
        let deviceToken = tokenData.base64EncodedString()
        let request = try self.requestBuilder.update(bits: bits, deviceToken: deviceToken)
        let (_, requestResponse) = try await self.urlSession.data(for: request)
        if (requestResponse as? HTTPURLResponse)?.statusCode != 200 {
            throw CheckError.wrongFormat
        }
    }
    
    public func query() async throws -> Bits {
        let tokenData = try await DCDevice.current.generateToken()
        let deviceToken = tokenData.base64EncodedString()
        let request = try self.requestBuilder.query(deviceToken: deviceToken)
        let (requestData, requestResponse) = try await self.urlSession.data(for: request)
        guard let json = try? JSONSerialization.jsonObject(with: requestData, options: .mutableContainers) as? [String: Any], let bit0 = json["bit0"] as? Int, let bit1 = json["bit1"] as? Int else {
            if (requestResponse as? HTTPURLResponse)?.statusCode == 200 {
                return Bits(bit0: false, bit1: false)
            } else {
                throw CheckError.wrongFormat
            }
        }
        return Bits(bit0: bit0 != 0, bit1: bit1 != 0)
    }
}

extension DeviceCheck {
    class RequestBuilder {
        private let p8: String
        
        private let keyId: String
        private let teamId: String
        private let developmentAPI: Bool
        
        private var baseUrl: String { self.developmentAPI ? "https://api.development.devicecheck.apple.com/v1/" : "https://api.devicecheck.apple.com/v1/" }
        
        private var endpointQuery: URLRequest { URLRequest(url: URL(string: self.baseUrl + "query_two_bits")!) }
        private var endpointUpdate: URLRequest { URLRequest(url: URL(string: self.baseUrl + "update_two_bits")!) }
        
        init(p8: String, keyId: String, teamId: String, developmentAPI: Bool) {
            self.p8 = p8
            self.keyId = keyId
            self.teamId = teamId
            self.developmentAPI = developmentAPI
        }
        
        func query(deviceToken: String) throws -> URLRequest {
            let jwt = JWT(keyID: self.keyId, teamID: self.teamId, issueDate: Date(), expireDuration: 60 * 60)
            let token = try jwt.sign(with: self.p8)
            var request = self.endpointQuery
            request.httpMethod = "POST"
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let json: [String: Any] = ["device_token": deviceToken, "transaction_id": UUID().uuidString, "timestamp": self.currentTimeInMilliSeconds()]
            request.httpBody = try? JSONSerialization.data(withJSONObject: json)
            return request
        }
        
        func update(bits: Bits, deviceToken: String) throws -> URLRequest {
            let jwt = JWT(keyID: self.keyId, teamID: self.teamId, issueDate: Date(), expireDuration: 60 * 60)
            let token = try jwt.sign(with: self.p8)
            var request = self.endpointUpdate
            request.httpMethod = "POST"
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let json: [String: Any] = ["device_token": deviceToken, "transaction_id": UUID().uuidString, "timestamp": self.currentTimeInMilliSeconds(), "bit0": bits.bit0, "bit1": bits.bit1]
            request.httpBody = try? JSONSerialization.data(withJSONObject: json)
            return request
        }

        private func currentTimeInMilliSeconds() -> Int {
            let currentDate = Date()
            let since1970 = currentDate.timeIntervalSince1970
            return Int(since1970 * 1000)
        }
    }
}
