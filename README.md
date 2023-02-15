[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)](https://github.com/apple/swift-package-manager)
![GitHub](https://img.shields.io/github/license/bandd-k/DeviceCheckServerless)

# DeviceCheckServerless

Apple allows to set and query of two binary digits of data per device, which are persistent even after uninstallation. For example, you might use this data to identify devices that have already taken advantage of a promotional offer that you provide or to flag a device that you’ve determined to be fraudulent.
DeviceCheck API is designed to be used with a server, but this small package allows you to do everything on the device. Note that an on-device solution is more vulnerable to hackers attacks
https://developer.apple.com/documentation/devicecheck/accessing_and_modifying_per-device_data


## Installation

### With Swift Package Manager
```ruby
https://github.com/bandd-k/DeviceCheckServerless.git
```

## How to Use

```swift
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
// init DeviceCheck with your own p8, keyID and teamID
// https://developer.apple.com/account/resources/authkeys/list generate key for DeviceCheck here
// https://developer.apple.com/account/#/membership/ find teamID here

let deviceCheck = DeviceCheck(p8: p8, keyId: keyID, teamId: teamID, developmentAPI: true)
let bits = try await deviceCheck.query()
print(bits)
try await deviceCheck.update(DeviceCheck.Bits(bit0: true, bit1: true))
```
