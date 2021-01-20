import Foundation
import Combine
import os.log
import AuthenticationServices
import WebKit

public class OAuth2Client: NSObject {

  private var cancellables: [AnyCancellable] = []

  public func signIn(with request: Request) -> Future<Credential, OAuth2Error> {
    return Future { [weak self] completion in
      guard let self = self else { return }
      guard let components = URLComponents(string: request.redirectUri),
            let callbackScheme = components.scheme else {
        completion(.failure(OAuth2Error.invalidRedirectUri))
        return
      }
      let pkce = PKCE()
      self.requestAuth(url: request.buildAuthorizeURL(pkce: pkce) , callbackScheme: callbackScheme)
        .flatMap { return self.requestToken(for: request.buildTokenURL(code: $0, pkce: pkce))}
        .sink { (result) in
          switch result {
            case .failure(let error):
              print(error)
              completion(.failure(error))
            default: break
          }
        } receiveValue: { credential in
          completion(.success(credential))
          print(credential)
        }
        .store(in: &self.cancellables)

    }
  }

  public func signOut(with request: Request) -> Future<Credential, OAuth2Error> {
    Future { finalCompletion in
      let dataTypes = Set([WKWebsiteDataTypeCookies, WKWebsiteDataTypeSessionStorage, WKWebsiteDataTypeLocalStorage, WKWebsiteDataTypeWebSQLDatabases, WKWebsiteDataTypeIndexedDBDatabases])
      Future<Void, Never> { completion in
        WKWebsiteDataStore.default().removeData(ofTypes: dataTypes, modifiedSince: Date.distantPast) {
          completion(.success(()))
        }
      }.flatMap {
        self.signIn(with: request)
      }
      .sink { (completion) in
        switch completion {
          case let .failure(error):
            finalCompletion(.failure(error))
          default:
            break
        }
      } receiveValue: { (value) in
        finalCompletion(.success(value))
      }
      .store(in: &self.cancellables)
    }
  }

  public func refresh(with request: Request, refreshToken: String) -> Future<Credential, OAuth2Error> {
    Future { [weak self] completion in
      guard let self = self else { return }
      self.requestToken(for: request.buildRefreshTokenURL(refreshToken: refreshToken))
        .sink { (result) in
          switch result {
            case .failure(let error):
              print(error)
              completion(.failure(error))
            default: break
          }
        } receiveValue: { credential in
          credential.save()
          completion(.success(credential))
          print(credential)
        }
        .store(in: &self.cancellables)
    }
  }
}

extension OAuth2Client: ASWebAuthenticationPresentationContextProviding {
  public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    .init()
  }
}

private extension OAuth2Client {
  func requestAuth(url: URL, callbackScheme: String) -> Future<String, OAuth2Error> {
    Future { [weak self] finalCompletion in
      guard let self = self else { return }
      Future<URL, OAuth2Error> { completion in
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackScheme) { (url, error) in
          if let error = error {
            completion(.failure(OAuth2Error.authError(error as NSError)))
          } else if let url = url {
            completion(.success(url))
          }
        }
        session.presentationContextProvider = self
        session.prefersEphemeralWebBrowserSession = true
        session.start()
      }.tryMap { url  in
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
          throw OAuth2Error.codeNotFound
        }
        return code
      }.sink { (completion) in
        switch completion {
          case .failure(let error):
            finalCompletion(.failure(OAuth2Error.authError(error as NSError)))
          default:
            break
        }
      } receiveValue: { code in
        finalCompletion(.success(code))
      }
      .store(in: &self.cancellables)
    }
  }

  func requestToken(for url: URL) -> AnyPublisher<Credential, OAuth2Error> {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")

    return URLSession.shared.dataTaskPublisher(for: request)
      .tryMap { data, response in
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
          throw OAuth2Error.urlError(URLError(.badServerResponse))
        }
        return data
      }
      .decode(type: Credential.self, decoder: JSONDecoder.convertFromSnakeCase)
      .mapError { OAuth2Error.decodingError($0 as NSError) }
      .eraseToAnyPublisher()
  }
}
