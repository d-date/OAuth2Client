import XCTest
@testable import OAuth2Client

final class OAuth2ClientTests: XCTestCase {

  /// see: https://tools.ietf.org/html/rfc7636#appendix-A
  func testBase64URLEncodingIsExpected() {
    let data = Data([3,236,255,224,193])
    XCTAssert(data.base64urlEncodedString() == "A-z_4ME")
  }

  /// see: https://tools.ietf.org/html/rfc7636#appendix-B
  func testSHA256IsExpected() {
    let codeVerifier = "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk"
    let bytes: [UInt8] = [19, 211, 30, 150, 26, 26, 216, 236, 47, 22, 177, 12, 76, 152, 46,
                          8, 118, 168, 120, 173, 109, 241, 68, 86, 110, 225, 137, 74, 203,
                          112, 249, 195]
    let expected = Data(bytes)
    XCTAssert(codeVerifier.data(using: .utf8)!.sha256() == expected)
  }

  /// see: https://tools.ietf.org/html/rfc7636#appendix-B
  func testCodeChallengeIsExpected() {
    let codeVerifier = "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk"

    let codeChallenge = PKCE.codeChallenge(codeVerifier: codeVerifier)
    print("code challenge:", codeChallenge)
    let expected = "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM"
    XCTAssert(PKCE.codeChallenge(codeVerifier: codeVerifier) == expected)
  }
}
