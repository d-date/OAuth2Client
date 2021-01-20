import Foundation

extension JSONDecoder {
  public static var convertFromSnakeCase: JSONDecoder = {
    $0.keyDecodingStrategy = .convertFromSnakeCase
    return $0
  }(JSONDecoder())

}
