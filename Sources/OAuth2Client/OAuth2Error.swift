import Foundation

public enum OAuth2Error: Equatable, LocalizedError {
  case invalidRedirectUri
  case codeNotFound
  case authError(NSError)
  case urlError(URLError)
  case decodingError(NSError)

  public var localizedDescription: String {
    switch self {
      case .invalidRedirectUri:
        return "Invalid Redirect Uri"
      case .codeNotFound:
        return "Response doesn't contain code"
      case let .urlError(error):
        return error.localizedDescription
      case let .decodingError(error), let .authError(error):
        return error.localizedDescription
    }
  }
}
