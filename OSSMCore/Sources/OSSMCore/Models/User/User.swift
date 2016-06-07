import Foundation
import Glibc
import SQL
import CryptoSwift
import PostgreSQL


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
    case DoesNotExist()
    case InvalidInput(fields: [ValidationError])
    case DuplicateKey(key: String)
    case Forbidden
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
  /// The User's email address, which is used in logging in. Max length: 255.
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
  /// A world-facing display name. Max length: 40.
  public var nickname: String
  /// The user's timezone, for example "Australia/Sydney". Max length: 40.
  /// This is not validated here as a real timezone, and should be validated in UI.
  public var timezone: String
  /// The user's preferred interface language. Max length: 8.
  /// This is not validated as a real language, and should be validated in UI.
  public var language: String
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

  May throw IntegrityError or UnhandledError on failure.
  */
  public init(row: Row) throws {
    do {
      let pk: Int = try row.value("pk")
      let email: String = try row.value("email")
      let passwordHash: String = try row.value("password")
      guard let authToken = try? AuthToken(string: try row.value("auth_token")) else {
        throw OSSMCore.Error.IntegrityError(debugMessage: "Invalid auth_token retrieved from database.", extra: row)
      }
      let verificationCode: String? = try? row.value("verification_code")
      let isActive = try row.value("is_active") as String == "t" ? true : false
      guard let accessLevel = AccessLevel(rawValue: try row.value("access_level")) else {
        throw OSSMCore.Error.IntegrityError(debugMessage: "Invalid access_level retrieved from database.", extra: row)
      }
      let nickname: String = try row.value("nickname")
      let timezone: String = try row.value("timezone")
      let language: String = try row.value("language")
      let faceRecipe: String = try row.value("face_recipe")
      guard let dateCreated = dbDateFromString(try row.value("date_created")) else {
        throw OSSMCore.Error.IntegrityError(debugMessage: "Invalid date_created retrieved from database.", extra: row)
      }
      let lastLogin: NSDate? = {
        if let string = try? row.value("last_login") as String {
          return dbDateFromString(string)
        }
        return nil
      }()
      self.init(pk: pk, email: email, passwordHash: passwordHash, authToken: authToken, verificationCode: verificationCode, isActive: isActive, accessLevel: accessLevel, nickname: nickname, timezone: timezone, language: language, faceRecipe: faceRecipe, dateCreated: dateCreated, lastLogin: lastLogin)
    } catch let error {
      throw OSSMCore.Error.UnhandledError(debugMessage: "Could not init User from database row.", extra: (row, error))
    }
  }

  /**
  Create a new User from the given attributes, store it in the database, and then return it.
  - Throws: User.Error.FetchError, User.Error.InitError, or an SQL error.

  - Warning: This function ignores all model validation.
  */
  public static func create(withEmail email: String, password: String, authToken: AuthToken, verificationCode: String?, isActive: Bool, accessLevel: AccessLevel, nickname: String, timezone: String, language: String, faceRecipe: String, dateCreated: NSDate, lastLogin: NSDate?) throws -> User {
    // TODO: Zewo's PostgreSQL cannot accept a nil value as a parameter - it tries to insert "NULL" not NULL. So until that
    // is fixed, I will need to do some yucky things.
    // Replace this method body with that quoted directly below.
    /*
    do {
      if let row = try db().execute(
        "INSERT INTO users (email, password, auth_token, verification_code, is_active, access_level, nickname, timezone, language, face_recipe, date_created, last_login) VALUES (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@) RETURNING *",
        parameters: email, hashedString(password), authToken.stringValue, verificationCode, isActive ? "t" : "f", accessLevel.rawValue, nickname, timezone, language, faceRecipe, dbStringFromDate(dateCreated), dbStringFromDate(lastLogin)
      ).first {
        return try User(row: row)
      }
      throw OSSMCore.Error.UnhandledError(debugMessage: "Insert query did not fail, but no User was returned.", extra: nil)
    } catch Result.Error.BadStatus(let status, let string) {
      // Catch duplicate keys
      if string.range(of: "duplicate key") != nil {
        if string.range(of: "users_email_key") != nil { throw User.Error.DuplicateKey(key: "email") }
        else if string.range(of: "users_nickname_key") != nil { throw User.Error.DuplicateKey(key: "nickname") }
        throw User.Error.DuplicateKey(key: string)
      }
      throw OSSMCore.Error.UnhandledError(debugMessage: "Could not insert User into the database. PSQL error: \(string)", extra: status)
    } catch let error {
      throw OSSMCore.Error.UnhandledError(debugMessage: "Could not insert User into the database.", extra: error)
    }
    */
    do {
      if let lastLogin = lastLogin {
        if let verificationCode = verificationCode {
          // lastLogin AND verificationCode
          if let row = try db().execute(
            "INSERT INTO users (email, password, auth_token, verification_code, is_active, access_level, nickname, timezone, language, face_recipe, date_created, last_login) VALUES (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@) RETURNING *",
            parameters: email, hashedString(password), authToken.stringValue, verificationCode, isActive ? "t" : "f", accessLevel.rawValue, nickname, timezone, language, faceRecipe, dbStringFromDate(dateCreated), dbStringFromDate(lastLogin)
          ).first {
            return try User(row: row)
          }
        } else {
          // lastLogin ONLY
          if let row = try db().execute(
            "INSERT INTO users (email, password, auth_token, verification_code, is_active, access_level, nickname, timezone, language, face_recipe, date_created, last_login) VALUES (%@, %@, %@, NULL, %@, %@, %@, %@, %@, %@, %@, %@) RETURNING *",
            parameters: email, hashedString(password), authToken.stringValue, isActive ? "t" : "f", accessLevel.rawValue, nickname, timezone, language, faceRecipe, dbStringFromDate(dateCreated), dbStringFromDate(lastLogin)
          ).first {
            return try User(row: row)
          }
        }
      } else if let verificationCode = verificationCode {
        // verificationCode ONLY
        if let row = try db().execute(
          "INSERT INTO users (email, password, auth_token, verification_code, is_active, access_level, nickname, timezone, language, face_recipe, date_created, last_login) VALUES (%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, NULL) RETURNING *",
          parameters: email, hashedString(password), authToken.stringValue, verificationCode, isActive ? "t" : "f", accessLevel.rawValue, nickname, timezone, language, faceRecipe, dbStringFromDate(dateCreated)
        ).first {
          return try User(row: row)
        }
      }
      // NEITHER
      if let row = try db().execute(
        "INSERT INTO users (email, password, auth_token, verification_code, is_active, access_level, nickname, timezone, language, face_recipe, date_created, last_login) VALUES (%@, %@, %@, NULL, %@, %@, %@, %@, %@, %@, %@, NULL) RETURNING *",
        parameters: email, hashedString(password), authToken.stringValue, isActive ? "t" : "f", accessLevel.rawValue, nickname, timezone, language, faceRecipe, dbStringFromDate(dateCreated)
      ).first {
        return try User(row: row)
      }
      throw OSSMCore.Error.UnhandledError(debugMessage: "Insert query did not fail, but no User was returned.", extra: nil)
    } catch Result.Error.BadStatus(let status, let string) {
      // Catch duplicate keys
      if string.range(of: "duplicate key") != nil {
        if string.range(of: "users_email_key") != nil { throw User.Error.DuplicateKey(key: "email") }
        else if string.range(of: "users_nickname_key") != nil { throw User.Error.DuplicateKey(key: "nickname") }
        throw User.Error.DuplicateKey(key: string)
      }
      throw OSSMCore.Error.UnhandledError(debugMessage: "Could not insert User into the database. PSQL error: \(string)", extra: status)
    } catch let error {
      throw OSSMCore.Error.UnhandledError(debugMessage: "Could not insert User into the database.", extra: error)
    }
  }

  /**
  Find and return a User from the database with the given primary key.
  Throws DoesNotExist if the User is not found.
  */
  public static func get(withPk pk: Int) throws -> User {
    if let row = try db().execute("SELECT * FROM users WHERE pk = %@", parameters: pk).first {
      return try User(row: row)
    }
    throw User.Error.DoesNotExist()
  }

  /**
  Given an AuthToken, find and potentially return a user's PK from the database which matches.
  Throws DoesNotExist if the User is not found.
  */
  public static func getPk(forAuthToken authToken: AuthToken) throws -> Int {
    if let row = try db().execute("SELECT pk FROM users WHERE auth_token = %@", parameters: authToken.stringValue).first {
      return try row.value("pk") as Int
    }
    throw User.Error.DoesNotExist()
  }


  static let emailRegex = try! NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}", options: [])
  static let validNicknameChars = Set("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890-_ ".characters)

  /**
  Create and save a new User object with some default parameters.
  The User's account will be created inactive and a verification code will be generated.
  This function validates its inputs.
  */
  public static func create(withEmail email: String, password: String, timezone: String, language: String, nickname: String) throws -> User {
    // Validate inputs
    var invalidFields: [ValidationError] = []
    // email
    if email.characters.count > 255 {
      invalidFields.append(ValidationError(fieldName: "email", failure: .Length))
    }
    if emailRegex.numberOfMatches(in: email, options: [], range: NSRange(location: 0, length: email.characters.count)) == 0 {
      invalidFields.append(ValidationError(fieldName: "email", failure: .Email))
    }
    // password
    if password.characters.count < 8 {
      invalidFields.append(ValidationError(fieldName: "password", failure: .Length))
    }
    // timezone
    if timezone.characters.count > 40 {
      invalidFields.append(ValidationError(fieldName: "timezone", failure: .Length))
    }
    // nickname
    if nickname.characters.count > 40 {
      invalidFields.append(ValidationError(fieldName: "nickname", failure: .Length))
    }
    if nickname.characters.filter({ validNicknameChars.contains($0) }).count != nickname.characters.count {
      invalidFields.append(ValidationError(fieldName: "nickname", failure: .Characters))
    }
    if invalidFields.count > 0 {
      throw User.Error.InvalidInput(fields: invalidFields)
    }

    // Save the new object.
    do {
      return try User.create(
        withEmail: email.lowercased(),
        password: password,
        authToken: try AuthToken.generateUnique(),
        verificationCode: AuthToken.generate().stringValue,
        isActive: false,
        accessLevel: AccessLevel.User,
        nickname: nickname,
        timezone: timezone,
        language: language,
        faceRecipe: "",
        dateCreated: NSDate(),
        lastLogin: nil)
    }
  }

  public func editProfile(timezone: String, language: String, nickname: String, email: String) throws {
    // Validate inputs
    var invalidFields: [ValidationError] = []
    // timezone
    if timezone.characters.count > 40 {
      invalidFields.append(ValidationError(fieldName: "timezone", failure: .Length))
    }
    // nickname
    if nickname.characters.count > 40 {
      invalidFields.append(ValidationError(fieldName: "nickname", failure: .Length))
    }
    if nickname.characters.filter({ User.validNicknameChars.contains($0) }).count != nickname.characters.count {
      invalidFields.append(ValidationError(fieldName: "nickname", failure: .Characters))
    }
    // email
    if email.characters.count > 255 {
      invalidFields.append(ValidationError(fieldName: "email", failure: .Length))
    }
    if User.emailRegex.numberOfMatches(in: email, options: [], range: NSRange(location: 0, length: email.characters.count)) == 0 {
      invalidFields.append(ValidationError(fieldName: "email", failure: .Email))
    }
    if invalidFields.count > 0 {
      throw User.Error.InvalidInput(fields: invalidFields)
    }
    // Save changes to the object
    do {
      try db().execute("UPDATE users SET timezone = %@, language = %@, nickname = %@, email = %@ WHERE pk = %@", parameters: timezone, language, nickname, email, pk)
    } catch Result.Error.BadStatus(let status, let string) {
    // Catch duplicate keys
    if string.range(of: "duplicate key") != nil {
      if string.range(of: "users_email_key") != nil { throw User.Error.DuplicateKey(key: "email") }
      else if string.range(of: "users_nickname_key") != nil { throw User.Error.DuplicateKey(key: "nickname") }
      throw User.Error.DuplicateKey(key: string)
    }
    throw OSSMCore.Error.UnhandledError(debugMessage: "Could not edit User's profile fields. PSQL error: \(string)", extra: status)
    } catch let error {
      throw OSSMCore.Error.UnhandledError(debugMessage: "Could not edit User's profile fields.", extra: error)
    }
  }

  /// Set user's password.
  public func changePassword(from oldPassword: String, to newPassword: String) throws {
    if newPassword.characters.count < 8 {
      throw User.Error.InvalidInput(fields: [ValidationError(fieldName: "password", failure: .Length)])
    }
    do {
      if try db().execute("SELECT 1 FROM users WHERE pk = %@ AND password = %@", parameters: pk, hashedString(oldPassword)).count != 1 {
        throw User.Error.Forbidden
      }
      try db().execute("UPDATE users SET password = %@ WHERE pk = %@", parameters: hashedString(newPassword), pk)
    } catch User.Error.Forbidden {
      throw User.Error.Forbidden
    } catch let error {
      throw OSSMCore.Error.UnhandledError(debugMessage: "Could not edit User's password.", extra: error)
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
    let passwordHash = hashedString(password)
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
    let passwordHash = hashedString(password)
    let result = try db().execute("SELECT pk FROM users WHERE pk = %@ AND password = %@ AND is_active = TRUE", parameters: pk, passwordHash)
    if let row = result.first {
      return try row.value("pk") as Int?
    }
    return nil
  }

  /**
  Recreates the User's auth token. Guaranteed to be new.
  */
  public func regenerateToken() throws -> AuthToken {
    // TODO: wrap this in a transaction
    let oldToken = authToken
    var newToken = authToken
    while oldToken == newToken {
      newToken = try AuthToken.generateUnique()
    }
    try db().execute("UPDATE users SET auth_token = %@ WHERE pk = %@", parameters: newToken.stringValue, pk)
    return newToken
  }

}
