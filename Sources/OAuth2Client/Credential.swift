import Foundation

public struct Credential: Equatable, Codable {
  public let accessToken: String
  public let tokenType: String
  public let refreshToken: String
  public let scope: String?
  public let expiresIn: Int?

  enum CodingKeys: String, CodingKey {
    case accessToken
    case tokenType
    case refreshToken
    case scope
    case expiresIn, expires
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    accessToken = try container.decode(String.self, forKey: .accessToken)
    tokenType = try container.decode(String.self, forKey: .tokenType)
    refreshToken = try container.decode(String.self, forKey: .refreshToken)
    scope = try? container.decode(String.self, forKey: .scope)

    var expiresIn: Int?
    if let expires = try? container.decode(Int.self, forKey: .expires) {
      expiresIn = expires
    } else if let expires = try? container.decode(Int.self, forKey: .expiresIn) {
      expiresIn = expires
    }
    self.expiresIn = expiresIn
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(accessToken, forKey: .accessToken)
    try container.encode(tokenType, forKey: .tokenType)
    try container.encode(refreshToken, forKey: .refreshToken)
    try? container.encode(scope, forKey: .scope)
    try? container.encode(expiresIn, forKey: .expiresIn)
  }
}

public extension Credential {
  private static let key = "CredentialKey"

  func save() {
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    encoder.outputFormatting = .prettyPrinted
    let data = try? encoder.encode(self)
    UserDefaults.standard.set(data, forKey: Credential.key)
  }

  static func load() -> Credential? {
    guard let credentialsData = UserDefaults.standard.data(forKey: key),
          let credentials = try? JSONDecoder.convertFromSnakeCase.decode(Credential.self, from: credentialsData) else { return nil }
    return credentials
  }

  static func remove() {
    UserDefaults.standard.setValue(nil, forKey: Credential.key)
  }
}
