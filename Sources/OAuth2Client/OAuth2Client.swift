import AuthenticationServices
import Foundation
import WebKit
import os.log

public actor OAuth2Client: NSObject {

  var logger: Logger

  public init(logger: Logger = .init()) {
    self.logger = logger
  }

  public func signIn(with request: Request, usePKCE: Bool = true) async throws -> Credential {
    guard let components = URLComponents(string: request.redirectUri),
          let callbackScheme = components.scheme
    else {
      throw OAuth2Error.invalidRedirectUri
    }
    let pkce = PKCE()
    let code = try await requestAuth(url: request.buildAuthorizeURL(pkce: usePKCE ? pkce : nil), callbackScheme: callbackScheme)
    let url = request.buildTokenURL(code: code, pkce: pkce)
    return try await requestToken(for: url)
  }

  public func signOut(with request: Request) async throws -> Credential {
    let dataTypes = Set([
      WKWebsiteDataTypeCookies, WKWebsiteDataTypeSessionStorage, WKWebsiteDataTypeLocalStorage,
      WKWebsiteDataTypeWebSQLDatabases, WKWebsiteDataTypeIndexedDBDatabases,
    ])
    await WKWebsiteDataStore.default().removeData(ofTypes: dataTypes, modifiedSince: Date.distantPast)
    return try await signIn(with: request)
  }

  public func refresh(with request: Request, refreshToken: String) async throws -> Credential {
    try await requestToken(for: request.buildRefreshTokenURL(refreshToken: refreshToken))
  }
}

extension OAuth2Client: ASWebAuthenticationPresentationContextProviding {
  nonisolated public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    .init()
  }
}

extension OAuth2Client {
  fileprivate func requestAuth(url: URL, callbackScheme: String) async throws -> String {
    let url: URL = try await withCheckedThrowingContinuation { continuation in
      let session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackScheme) { url, error in
        if let error = error {
          continuation.resume(throwing: OAuth2Error.authError(error as NSError))
        } else if let url = url {
          continuation.resume(returning: url)
        }
      }
      session.presentationContextProvider = self
      session.prefersEphemeralWebBrowserSession = true
      session.start()
    }

    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
          let code = components.queryItems?.first(where: { $0.name == "code" })?.value
    else {
      throw OAuth2Error.codeNotFound
    }
    return code
  }

  fileprivate func requestToken(for url: URL) async throws -> Credential {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")

    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
      throw OAuth2Error.urlError(URLError(.badServerResponse))
    }
    do {
      return try JSONDecoder.convertFromSnakeCase.decode(Credential.self, from: data)
    } catch {
      throw OAuth2Error.decodingError(error as NSError)
    }
  }
}
