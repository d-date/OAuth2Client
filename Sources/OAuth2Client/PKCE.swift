import Foundation
import CommonCrypto
import CryptoKit
import os.log

public struct PKCE {
  public let codeVerifier: String
  public let codeChallenge: String
  public let codeChallengeMethod: String
  public let state: String

  init() {
    self.codeVerifier = Self.randomString(size: (43...128).randomElement()!)
    self.state = Self.randomString()
    self.codeChallenge = Self.codeChallenge(codeVerifier: self.codeVerifier)
    self.codeChallengeMethod = "S256"
  }

  public static func codeChallenge(codeVerifier: String) -> String {
    return codeVerifier
      .data(using: .utf8)!
      .sha256()
      .base64urlEncodedString()
  }

  private static func randomString(size: Int = 32) -> String {
    precondition(size > 0)

    var bytes = [UInt8](repeating: 0, count: size)
    let status = CCRandomGenerateBytes(&bytes, bytes.count)
    if status != kCCSuccess {
      fatalError("Common Crypto Error: \(status)")
    }
    let data = Data(bytes: bytes, count: bytes.count)
    return data.base64urlEncodedString()
  }
}

extension Data {
  public func sha256() -> Data {
    .init(SHA256.hash(data: self))
  }

  public func base64urlEncodedString() -> String {
    self.base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "=", with: "")
  }
}
