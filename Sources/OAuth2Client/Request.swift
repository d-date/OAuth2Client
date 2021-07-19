import Foundation
import os.log

public struct Request {
  let authorizeURL: String
  let tokenURL: String
  let clientId: String
  let redirectUri: String
  let scopes: [String]

  public init(authorizeURL: String, tokenURL: String, clientId: String, redirectUri: String, scopes: [String]) {
    self.authorizeURL = authorizeURL
    self.tokenURL = tokenURL
    self.clientId = clientId
    self.redirectUri = redirectUri
    self.scopes = scopes
  }
}

extension Request {
  public func buildAuthorizeURL(pkce: PKCE? = nil) -> URL {
    var queryItems = [
      URLQueryItem(name: "client_id", value: clientId),
      URLQueryItem(name: "redirect_uri", value: redirectUri),
      URLQueryItem(name: "response_type", value: "code"),
      URLQueryItem(name: "scope", value: scopes.joined(separator: "+"))
    ]

    if let pkce = pkce {
      queryItems.append(.init(name: "code_challenge", value: pkce.codeChallenge))
      queryItems.append(.init(name: "code_challenge_method", value: pkce.codeChallengeMethod))
    }

    var components = URLComponents(string: authorizeURL)!
    components.queryItems = queryItems
    return components.url!
  }

  func buildTokenURL(code: String, pkce: PKCE? = nil) -> URL {
    var queryItems = [
      URLQueryItem(name: "client_id", value: clientId),
      URLQueryItem(name: "code", value: code),
      URLQueryItem(name: "grant_type", value: "authorization_code"),
      URLQueryItem(name: "redirect_uri", value: redirectUri)
    ]

    if let pkce = pkce {
      queryItems.append(.init(name: "code_verifier", value: pkce.codeVerifier))
    }

    var components = URLComponents(string: tokenURL)!
    components.queryItems = queryItems
    return components.url!
  }

  func buildRefreshTokenURL(refreshToken: String) -> URL {
    let queryItems = [
      URLQueryItem(name: "client_id", value: clientId),
      URLQueryItem(name: "grant_type", value: "refresh_token"),
      URLQueryItem(name: "refresh_token", value: refreshToken)
    ]
    var components = URLComponents(string: tokenURL)!
    components.queryItems = queryItems
    return components.url!
  }
}
