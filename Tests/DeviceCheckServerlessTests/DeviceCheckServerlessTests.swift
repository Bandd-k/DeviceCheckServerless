//
//  DeviceCheckServerlessTests.swift
//  DeviceCheckServerless
//
//  Created by Denis Karpenko on 15.02.2023.
//

import XCTest
@testable import DeviceCheckServerless

final class DeviceCheckServerlessTests: XCTestCase {
    let keyID = "GG8TWG834Q"
    let teamID = "SE9N6X5V7C"
    let p8 = """
-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgGH2MylyZjjRdauTk
xxXW6p8VSHqIeVRRKSJPg1xn6+KgCgYIKoZIzj0DAQehRANCAAS/mNzQ7aBbIBr3
DiHiJGIDEzi6+q3mmyhH6ZWQWFdFei2qgdyM1V6qtRPVq+yHBNSBebbR4noE/IYO
hMdWYrKn
-----END PRIVATE KEY-----
"""
    func testQueryRequestBody() throws {
        let requestBuilder = DeviceCheck.RequestBuilder(p8: self.p8, keyId: self.keyID, teamId: self.teamID, developmentAPI: true)
        let request = try requestBuilder.query(deviceToken: "dummyToken")
        
        XCTAssertEqual(request.httpMethod, "POST")
        let headers = try XCTUnwrap(request.allHTTPHeaderFields)
        XCTAssertNotNil(headers["Authorization"])
        XCTAssertNotNil(headers["Content-Type"])
        
        let body = try XCTUnwrap(request.httpBody)
        let json = try JSONSerialization.jsonObject(with: body, options: .mutableContainers) as! [String: Any]
        XCTAssertNotNil(json["device_token"])
        XCTAssertNotNil(json["transaction_id"])
        XCTAssertNotNil(json["timestamp"])
        
        XCTAssertNil(json["bit0"])
        XCTAssertNil(json["bit1"])
    }
    
    func testUpdateRequestBody() throws {
        let requestBuilder = DeviceCheck.RequestBuilder(p8: self.p8, keyId: self.keyID, teamId: self.teamID, developmentAPI: true)
        let request = try requestBuilder.update(bits: .init(bit0: true, bit1: false), deviceToken: "dummyToken")
        
        XCTAssertEqual(request.httpMethod, "POST")
        let headers = try XCTUnwrap(request.allHTTPHeaderFields)
        XCTAssertNotNil(headers["Authorization"])
        XCTAssertNotNil(headers["Content-Type"])
        
        let body = try XCTUnwrap(request.httpBody)
        let json = try JSONSerialization.jsonObject(with: body, options: .mutableContainers) as! [String: Any]
        XCTAssertNotNil(json["device_token"])
        XCTAssertNotNil(json["transaction_id"])
        XCTAssertNotNil(json["timestamp"])
        
        XCTAssertEqual(json["bit0"] as? Bool, true)
        XCTAssertEqual(json["bit1"] as? Bool, false)
    }
    
    func testRequestURLDevelopment() throws {
        let requestBuilder = DeviceCheck.RequestBuilder(p8: self.p8, keyId: self.keyID, teamId: self.teamID, developmentAPI: true)
        var request = try requestBuilder.query(deviceToken: "dummyToken")
        
        XCTAssertEqual(request.url?.absoluteString, "https://api.development.devicecheck.apple.com/v1/query_two_bits")
        
        request = try requestBuilder.update(bits: .init(bit0: false, bit1: false), deviceToken: "dummyToken")
        XCTAssertEqual(request.url?.absoluteString, "https://api.development.devicecheck.apple.com/v1/update_two_bits")
    }
    
    func testRequestURLNonDevelopment() async throws {
        let requestBuilder = DeviceCheck.RequestBuilder(p8: self.p8, keyId: self.keyID, teamId: self.teamID, developmentAPI: false)
        var request = try requestBuilder.query(deviceToken: "dummyToken")
        
        XCTAssertEqual(request.url?.absoluteString, "https://api.devicecheck.apple.com/v1/query_two_bits")
        
        request = try requestBuilder.update(bits: .init(bit0: false, bit1: false), deviceToken: "dummyToken")
        XCTAssertEqual(request.url?.absoluteString, "https://api.devicecheck.apple.com/v1/update_two_bits")
    }
}
