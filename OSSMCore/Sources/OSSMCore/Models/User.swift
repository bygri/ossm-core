import Foundation
import Glibc
import SQL
import CryptoSwift

/**
A User represents a real individual who is playing the game. They have credentials, basic public profile info,
and some internal properties.

Users generally identify themselves to the API per request using a secret AuthToken, which should be cached by an API.
*/
public struct User {

  /**
  The various types of error that can be thrown by the User struct.
  */
  public enum Error: ErrorProtocol {
    case InitError(String)
    case FetchError(String)
    case DoesNotExist(String)
  }

  /**
  Instead of providing a password with each API request, clients should provide an auth token. This is a 20-character
  random string. The API should cache this token as every request from a given user must include it.

  The AuthToken.generate() method will create a new auth token.
  */
  public struct AuthToken {

    private var str: String

    /// This is the set of characters which may be included in an AuthToken.
    private static let validCharacters: Set<Character> = [
      "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
      "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
      "1","2","3","4","5","6","7", "8", "9", "0"
    ]

    /// Initialise the AuthToken with the given string. If the string is not a valid token, nil will be returned.
    public init?(string: String) {
      if !AuthToken.isValid(string: string) {
        return nil
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
      return AuthToken(string: str)!
    }
  }

  /**
  Users are granted various permissions based on their access level.
  */
  public enum AccessLevel: UInt {
    case User = 1
    case Moderator = 20
    case Administrator = 30
    case Superuser = 99
  }

  /// The primary key for this User. Unique.
  public var pk: Int
  /// The User's email address, which is used in logging in.
  public var email: String
  /// The User's hashed password.
  private var passwordHash: String
  /// The User's auth token, which is used to authenticate the user after initial log-in. Verified unique.
  public var authToken: AuthToken
  /// If this is set, then the User can make their account active by providing this code to the verify() method.
  public var verificationCode: String?
  /// If false, the user must not be granted access. See verificationCode.
  public var isActive: Bool
  /// The level of access this user is granted.
  public var accessLevel: AccessLevel
  /// A world-facing display name.
  public var nickname: String
  /// The user's timezone, for example "Australia/Sydney".
  public var timezoneName: String
  /// The user's preferred interface langauage.
  public var language: Language
  /// A string used to describe the user's chosen face, or avatar.
  public var faceRecipe: String
  /// The date the user account was first created.
  public var dateCreated: NSDate
  /// The date the user last logged in.
  public var lastLogin: NSDate?

}


// Database access
extension User {

  /**
  Init a User from an SQL row.
  - Throws: User.Error.InitError on failure.
  */
  public init(row: Row) throws {
    do {
      let pk: Int = try row.value("pk")
      let email: String = try row.value("email")
      let passwordHash: String = try row.value("password")
      guard let authToken = AuthToken(string: try row.value("auth_token")) else {
        throw User.Error.InitError("Invalid auth token")
      }
      let verificationCode: String? = try? row.value("verification_code")
      let isActive = try row.value("is_active") as String == "t" ? true : false
      guard let accessLevel = AccessLevel(rawValue: try row.value("access_level")) else {
        throw User.Error.InitError("Invalid access level")
      }
      let nickname: String = try row.value("nickname")
      let timezoneName: String = try row.value("timezone_name")
      guard let language = Language(rawValue: try row.value("language_code")) else {
        throw User.Error.InitError("Invalid language code")
      }
      let faceRecipe: String = try row.value("face_recipe")
      guard let dateCreated = dbDateFromString(try row.value("date_created")) else {
        throw User.Error.InitError("Invalid date created")
      }
      let lastLogin: NSDate? = {
        if let string = try? row.value("last_login") as String {
          return dbDateFromString(string)
        }
        return nil
      }()
      self.init(pk: pk, email: email, passwordHash: passwordHash, authToken: authToken, verificationCode: verificationCode, isActive: isActive, accessLevel: accessLevel, nickname: nickname, timezoneName: timezoneName, language: language, faceRecipe: faceRecipe, dateCreated: dateCreated, lastLogin: lastLogin)
    } catch let error {
      throw User.Error.InitError("Could not init User from row \(row) because \(error).")
    }
  }

  /**
  Create a new User from the given attributes, store it in the database, and then return it.
  - Throws: User.Error.FetchError, User.Error.InitError, or an SQL error.
  */
  public static func create(withEmail email: String, password: String, authToken: AuthToken, verificationCode: String?, isActive: Bool, accessLevel: AccessLevel, nickname: String, timezoneName: String, language: Language, faceRecipe: String, dateCreated: NSDate, lastLogin: NSDate?) throws -> User {
    // TODO: Zewo's PostgreSQL cannot accept a nil value as a parameter - it tries to insert "NULL" not NULL. So until that
    // is fixed, I will need to do some yucky things.
    // Replace this method body with that quoted directly below.
    /*
    if let row = try db().execute(
      "INSERT INTO users (email, password, auth_token, verification_code, is_active, access_level, nickname, timezone_name, language_code, face_recipe, date_created, last_login) VALUES (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@) RETURNING *",
      parameters: email, hashString(password), authToken.stringValue, verificationCode, isActive ? "t" : "f", accessLevel.rawValue, nickname, timezoneName, language.rawValue, faceRecipe, dbStringFromDate(dateCreated), dbStringFromDate(lastLogin)
    ).first {
      return try User(row: row)
    }
    throw User.Error.FetchError("No User was returned after Insert query.")
    */
    if let lastLogin = lastLogin {
      if let verificationCode = verificationCode {
        // lastLogin AND verificationCode
        if let row = try db().execute(
          "INSERT INTO users (email, password, auth_token, verification_code, is_active, access_level, nickname, timezone_name, language_code, face_recipe, date_created, last_login) VALUES (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@) RETURNING *",
          parameters: email, hashString(password), authToken.stringValue, verificationCode, isActive ? "t" : "f", accessLevel.rawValue, nickname, timezoneName, language.rawValue, faceRecipe, dbStringFromDate(dateCreated), dbStringFromDate(lastLogin)
        ).first {
          return try User(row: row)
        }
      } else {
        // lastLogin ONLY
        if let row = try db().execute(
          "INSERT INTO users (email, password, auth_token, verification_code, is_active, access_level, nickname, timezone_name, language_code, face_recipe, date_created, last_login) VALUES (%@, %@, %@, NULL, %@, %@, %@, %@, %@, %@, %@, %@) RETURNING *",
          parameters: email, hashString(password), authToken.stringValue, isActive ? "t" : "f", accessLevel.rawValue, nickname, timezoneName, language.rawValue, faceRecipe, dbStringFromDate(dateCreated), dbStringFromDate(lastLogin)
        ).first {
          return try User(row: row)
        }
      }
    } else if let verificationCode = verificationCode {
      // verificationCode ONLY
      if let row = try db().execute(
        "INSERT INTO users (email, password, auth_token, verification_code, is_active, access_level, nickname, timezone_name, language_code, face_recipe, date_created, last_login) VALUES (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, NULL) RETURNING *",
        parameters: email, hashString(password), authToken.stringValue, verificationCode, isActive ? "t" : "f", accessLevel.rawValue, nickname, timezoneName, language.rawValue, faceRecipe, dbStringFromDate(dateCreated)
      ).first {
        return try User(row: row)
      }
    }
    // NEITHER
    if let row = try db().execute(
      "INSERT INTO users (email, password, auth_token, verification_code, is_active, access_level, nickname, timezone_name, language_code, face_recipe, date_created, last_login) VALUES (%@, %@, %@, NULL, %@, %@, %@, %@, %@, %@, %@, NULL) RETURNING *",
      parameters: email, hashString(password), authToken.stringValue, isActive ? "t" : "f", accessLevel.rawValue, nickname, timezoneName, language.rawValue, faceRecipe, dbStringFromDate(dateCreated)
    ).first {
      return try User(row: row)
    }
    throw User.Error.FetchError("No User was returned after Insert query.")
  }

  /**
  Find and return a User from the database with the given primary key.
  Throws DoesNotExist if the User is not found.
  */
  public static func get(withPk pk: Int) throws -> User {
    if let row = try db().execute("SELECT * FROM users WHERE pk = %@", parameters: pk).first {
      return try User(row: row)
    }
    throw User.Error.DoesNotExist("User with pk \(pk) was not found.")
  }

  /**
  Given an AuthToken, find and potentially return a user's PK from the database which matches.
  */
  public static func getPk(forAuthToken authToken: User.AuthToken) throws -> Int? {
    if let row = try db().execute("SELECT pk FROM users WHERE auth_token = %@", parameters: authToken.stringValue).first {
      return try row.value("pk") as Int?
    }
    return nil
  }

  /**
  Create and save a new User object with some default parameters.
  The User's account will be created inactive and a verification code will be generated.
  */
  public static func create(withEmail email: String, password: String, timezoneName: String, language: Language, nickname: String) throws -> User {
    do {
      return try User.create(
        withEmail: email,
        password: password,
        authToken: try AuthToken.generateUnique(),
        verificationCode: AuthToken.generate().stringValue,
        isActive: false,
        accessLevel: AccessLevel.User,
        nickname: nickname,
        timezoneName: timezoneName,
        language: language,
        faceRecipe: "",
        dateCreated: NSDate(),
        lastLogin: nil)
    }
  }

  /// Set user as not active and generate a verification code to reactivate.
  public func requireVerification() throws {
    let code = AuthToken.generate().stringValue
    try db().execute("UPDATE users SET verification_code = %@, is_active = FALSE WHERE pk = %@", parameters: code, pk)
  }

  /// If the verification code matches, set user as active and return True. Otherwise return False.
  public func verify(withCode code: String) throws -> Bool {
    if code == verificationCode {
      try db().execute("UPDATE users SET verification_code = NULL, is_active = TRUE WHERE pk = %@", parameters: pk)
      return true
    }
    return false
  }

  /**
  Return a pk if the user's credentials are correct and the user is active.
  */
  public static func authenticateUser(withEmail email: String, password: String) throws -> Int? {
    let passwordHash = hashString(password)
    let result = try db().execute("SELECT pk FROM users WHERE email = %@ AND password = %@ AND is_active = TRUE", parameters: email, passwordHash)
    if let row = result.first {
      return try row.value("pk") as Int?
    }
    return nil
  }

  /**
  Return a pk if the user's credentials are correct and the user is active.
  */
  public static func authenticateUser(withPk pk: Int, password: String) throws -> Int? {
    let passwordHash = hashString(password)
    let result = try db().execute("SELECT pk FROM users WHERE pk = %@ AND password = %@ AND is_active = TRUE", parameters: pk, passwordHash)
    if let row = result.first {
      return try row.value("pk") as Int?
    }
    return nil
  }

  /**
  Recreates the User's auth token. Guaranteed to be new.
  */
  public func regenerateToken() throws -> User.AuthToken {
    let oldToken = authToken
    var newToken = authToken
    while oldToken == newToken {
      newToken = try User.AuthToken.generateUnique()
    }
    try db().execute("UPDATE users SET auth_token = %@ WHERE pk = %@", parameters: newToken.stringValue, pk)
    return newToken
  }

}


extension User.AuthToken {
  /**
  As generate(), but guarantees uniqueness by checking with the database.
  */
  public static func generateUnique() throws -> User.AuthToken {
    // TODO: wrap this in a transaction
    var token = User.AuthToken.generate()
    var matchedPk = try User.getPk(forAuthToken: token)
    while matchedPk != nil {
      token = User.AuthToken.generate()
      matchedPk = try User.getPk(forAuthToken: token)
    }
    return token
  }
}

extension User.AuthToken: Equatable {}
public func ==(lhs: User.AuthToken, rhs: User.AuthToken) -> Bool {
  return lhs.stringValue == rhs.stringValue
}
