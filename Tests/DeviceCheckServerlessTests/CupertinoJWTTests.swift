//
//  CupertinoJWTTests.swift
//  CupertinoJWTTests
//
//  Created by Ethanhuang on 2018/8/23.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//
import XCTest
@testable import DeviceCheckServerless

class CupertinoJWTTests: XCTestCase {
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

    func testJWT() {
        let jwt = JWT(keyID: keyID, teamID: teamID, issueDate: Date(), expireDuration: 60 * 60)
        do {
            let token = try jwt.sign(with: p8)
            print("Generated JWT: \(token)")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
