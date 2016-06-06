import Foundation
import Glibc
import SQL
import CryptoSwift
import PostgreSQL


/**
Instead of providing a password with each API request, clients should provide an auth token. This is a 20-character
random string. The API should cache this token as every request from a given user must include it.

The AuthToken.generate() method will create a new auth token.
*/
public struct AuthToken {

  public enum Error: ErrorProtocol {
    case InvalidTokenString
  }

  private var str: String

  /// This is the set of characters which may be included in an AuthToken.
  private static let validCharacters: Set<Character> = [
    "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
    "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
    "1","2","3","4","5","6","7", "8", "9", "0"
  ]

  /// Initialise the AuthToken with the given string. If the string is not a valid token, nil will be returned.
  public init(string: String) throws {
    if !AuthToken.isValid(string: string) {
      throw AuthToken.Error.InvalidTokenString
    }
    str = string
  }

  /// Returns the AuthToken as a string.
  public var stringValue: String {
    get {
      return str
    }
  }

  /// Checks that a passed-in string can be used to generate a valid AuthToken.
  public static func isValid(string: String) -> Bool {
    // A valid token must be 20 characters long and only contain characters from a simple set
    if string.characters.count != 20 { return false }
    for character in string.characters {
      if !AuthToken.validCharacters.contains(character) {
        return false
      }
    }
    return true
  }

  /// Generates a brand new AuthToken. Use generateUnique() instead if a database is bieng used.
  public static func generate() -> AuthToken {
    srandom(UInt32(NSDate().timeIntervalSinceReferenceDate))
    let chars = Array(AuthToken.validCharacters)
    let count = chars.count
    var str = ""
    for _ in 0..<20 {
      let r = Int(random() % count)
      str.append(chars[r])
    }
    return try! AuthToken(string: str)
  }
}


extension AuthToken {
  /**
  As generate(), but guarantees uniqueness by checking with the database.
  */
  public static func generateUnique() throws -> AuthToken {
    // TODO: wrap this in a transaction
    var token = AuthToken.generate()
    var matchedPk = try? User.getPk(forAuthToken: token)
    while matchedPk != nil {
      token = AuthToken.generate()
      matchedPk = try? User.getPk(forAuthToken: token)
    }
    return token
  }
}


extension AuthToken: Equatable {}
public func ==(lhs: AuthToken, rhs: AuthToken) -> Bool {
  return lhs.stringValue == rhs.stringValue
}
