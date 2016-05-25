import Foundation
import SQL


public struct User {

  public struct AuthToken {
    private var str: String
    private static var validCharacters: Set<Character> = [
      "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
      "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
      "1","2","3","4","5","6","7", "8", "9", "0"
    ]

    public init?(string: String) {
      if !AuthToken.isValid(string: string) {
        return nil
      }
      str = string
    }

    public var stringValue: String {
      get {
        return str
      }
    }

    private static func isValid(string: String) -> Bool {
      // A valid token must be 20 characters long and only contain characters from a simple set
      if string.characters.count != 20 { return false }
      for character in string.characters {
        if !AuthToken.validCharacters.contains(character) {
          return false
        }
      }
      return true
    }
  }

  public enum AccessLevel: UInt {
    case User = 1
    case Moderator = 20
    case Administrator = 30
    case Superuser = 99
  }

  public var pk: Int
  public var email: String
//   public var password: String // This is not readable
  public var token: AuthToken
  public var timezoneName: String
  public var language: Language
  public var isActive: Bool
  public var nickname: String
  public var faceRecipe: String
  public var accessLevel: AccessLevel
  public var lastLogin: NSDate?

  public init(pk: Int, email: String, token: AuthToken, timezoneName: String, language: Language, isActive: Bool, nickname: String, faceRecipe: String, accessLevel: AccessLevel, lastLogin: NSDate?) {
    self.pk = pk
    self.email = email
    self.token = token
    self.timezoneName = timezoneName
    self.language = language
    self.isActive = isActive
    self.nickname = nickname
    self.faceRecipe = faceRecipe
    self.accessLevel = accessLevel
    self.lastLogin = lastLogin
  }

}


// Database access
extension User {

  // Create a User from an SQL.Row
  public init?(row: Row) {
    do {
      guard let
        pk: Int = try row.value("pk"),
        email: String = try row.value("email"),
        tokenString: String = try row.value("token"), token = AuthToken(string: tokenString),
        timezoneName: String = try row.value("timezone_name"),
        languageString: String = try row.value("language_code"), language = Language(rawValue: languageString),
        isActiveChar: String = try row.value("is_active"),
        nickname: String = try row.value("nickname"),
        faceRecipe: String = try row.value("face_recipe"),
        accessLevelInt: UInt = try row.value("access_level"), accessLevel = AccessLevel(rawValue: accessLevelInt)
      else {
        return nil
      }
      self.init(pk: pk, email: email, token: token, timezoneName: timezoneName, language: language, isActive: isActiveChar == "t" ? true : false, nickname: nickname, faceRecipe: faceRecipe, accessLevel: accessLevel, lastLogin: nil)
    } catch {
      return nil
    }
  }
  
  public static func create(withEmail email: String, password: String, authToken: AuthToken, timezoneName: String, language: Language, isActive: Bool, nickname: String, faceRecipe: String, accessLevel: AccessLevel) throws -> User? {
    let result = try db().execute("INSERT INTO users (email, password, token, timezone_name, language_code, is_active, nickname, face_recipe, access_level, last_login) VALUES (%@, %@, %@, %@, %@, %@, %@, %@, %@, NULL) RETURNING *",
      parameters: email, password, authToken.stringValue, timezoneName, language.rawValue, isActive ? "t" : "f", nickname, faceRecipe, accessLevel.rawValue)
    if let row = result.first {
      return User(row: row)
    }
    return nil
  }

  // Return all Users
  public static func all() -> [User] {
    do {
      let result = try db().execute("SELECT * FROM users")
      return result.flatMap({ User(row: $0) })
    } catch {
      log("SQL error: \(db().mostRecentError)")
    }
    return []
  }

  // Return a User with a PK, or nil if it doesn't exist
  public static func get(withPk pk: Int) -> User? {
    do {
      if let
        row = try db().execute("SELECT * FROM users WHERE pk = %@", parameters: pk).first,
        user = User(row: row)
      {
        return user
      }
    } catch {
      log("SQL error: \(db().mostRecentError)")
    }
    return nil
  }

  // Return the PK of the User with the specified token, or nil
  public static func getPk(forToken token: User.AuthToken) -> Int? {
    do {
      if let
        row = try db().execute("SELECT pk FROM users WHERE token = %@", parameters: token.stringValue).first,
        pk: Int = try row.value("pk")
      {
        return pk
      }
      return nil
    } catch {
      log("SQL error: \(db().mostRecentError)")
      return nil
    }
  }

}
