import Foundation
import XCTest
@testable import OSSMCore


class UserTests: XCTestCase {

  override func setUp() {
    setLogLevel(.Debug)
    prepareTestDatabase()
  }

  func createTestUser(email: String = "test@test.com", password: String = "apassword") throws -> User {
    return try User.create(
      withEmail: email,
      password: password,
      authToken: try AuthToken.generateUnique(),
      verificationCode: nil,
      isActive: true,
      accessLevel: User.AccessLevel.User,
      nickname: "testuser",
      timezone: "Australia/Sydney",
      language: "en-au",
      faceRecipe: "",
      dateCreated: NSDate(),
      lastLogin: nil
    )
  }

  func testAuthToken() {
    // Init with a valid token string
    do {
      try _ = AuthToken(string: "ABCDEFabcdef12345600")
    } catch {
      XCTFail("The token should be valid.")
    }
  }

  func testAuthTokenStringValue() {
    // Test conversion to and from a token string
    let string = "ABCDEFabcdef12345600"
    do {
      let token = try AuthToken(string: string)
      XCTAssertEqual(string, token.stringValue)
    } catch {
      XCTFail("The token should be valid.")
      return
    }
  }

  func testInvalidAuthTokens() {
    // Try initing with invalid token strings
    do {
      try _ = AuthToken(string: "too short")
      XCTFail("A short token string should be invalid.")
    } catch {}
    do {
      try _ = AuthToken(string: "too long long long far too long")
      XCTFail("A long token string should be invalid.")
    } catch {}
    do {
      try _ = AuthToken(string: "inv@lid character$")
      XCTFail("A token string should not contain invalid characters.")
    } catch {}
  }

  func testGenerateAuthToken() {
    XCTAssertNotNil(AuthToken.generate())
  }

  func testGenerateUniqueAuthToken() {
    XCTAssertNotNil(try? AuthToken.generateUnique())
  }

  func testCreateUser() {
    do {
      let generatedToken = try AuthToken.generateUnique()
      let now = NSDate()
      let createdUser = try User.create(
        withEmail: "test@test.com",
        password: "password",
        authToken: generatedToken,
        verificationCode: nil,
        isActive: true,
        accessLevel: User.AccessLevel.User,
        nickname: "testuser",
        timezone: "Australia/Sydney",
        language: "en-au",
        faceRecipe: "",
        dateCreated: now,
        lastLogin: nil
      )
      XCTAssertNotNil(createdUser ,"A User should be created and returned")
      let user = try User.get(withPk: createdUser.pk)
      XCTAssertEqual(user.email, "test@test.com")
      XCTAssertEqual(user.authToken, generatedToken)
      XCTAssertEqual(user.verificationCode, nil)
      XCTAssertEqual(user.isActive, true)
      XCTAssertEqual(user.accessLevel, User.AccessLevel.User)
      XCTAssertEqual(user.nickname, "testuser")
      XCTAssertEqual(user.timezone, "Australia/Sydney")
      XCTAssertEqual(user.language, "en-au")
      XCTAssertEqual(user.faceRecipe, "")
      XCTAssertTrue((user.dateCreated.timeIntervalSince(now)) < 100)
      XCTAssertEqual(user.lastLogin, nil)
    } catch let error {
      XCTFail("\(error)")
    }
  }

  func testSignupFlow() {
    do {
      // Create a user.
      let email = "test@test.com"
      let password = "testpassword"
      let user = try User.create(
        withEmail: email,
        password: password,
        timezone: "Australia/Sydney",
        language: "en-au",
        nickname: "testuser")
      guard let verificationCode = user.verificationCode else {
        XCTFail("A verification code should have been generated.")
        return
      }
      // Attempt authentication - should fail.
      XCTAssertNil(
        try User.authenticateUser(withEmail: email, password: password),
        "Authenticating an inactive user should fail."
      )
      // Attempt authentication with incorrect credentials - should fail
      XCTAssertNil(
        try User.authenticateUser(withEmail: email, password: "thisisnotyourpassword"),
        "Authenticating an inactive user with incorrect credentials should fail."
      )
      // Verify with an incorrect code.
      XCTAssertFalse(
        try user.verify(withCode: "NOTREALLYACODE"),
        "Verifying a user with an incorrect code should fail."
      )
      // Attempt authentication - should fail.
      XCTAssertNil(
        try User.authenticateUser(withEmail: email, password: password),
        "Authenticating an inactive user who was then verified incorrectly should fail."
      )
      // Verify with a correct code
      XCTAssertTrue(
        try user.verify(withCode: verificationCode),
        "Verifying a user with a correct code should succeed."
      )
      // Attempt authentication with incorrect credentials - should fail
      XCTAssertNil(
        try User.authenticateUser(withEmail: email, password: "thisisnotyourpassword"),
        "Authenticating an active user with incorrect credentials should fail."
      )
      // Attempt authentication - should succeed.
      print("pw \(password)")
      XCTAssertNotNil(
        try User.authenticateUser(withEmail: email, password: password),
        "Authenticating an active user with correct email and password should succeed."
      )
    } catch let error {
      XCTFail("\(error)")
    }
  }

  func testAuthentication() {
    do {
      // Create an active user.
      let email = "test@test.com"
      let password = "apassword"
      let user = try createTestUser(email: email, password: password)
      // Try authentication
      XCTAssertNil(
        try User.authenticateUser(withEmail: "notyouremail@email.com", password: password),
        "Authenticating with incorrect email should fail."
      )
      XCTAssertNil(
        try User.authenticateUser(withEmail: email, password: "not your password"),
        "Authenticating with incorrect password should fail."
      )
      XCTAssertNotNil(
        try User.authenticateUser(withEmail: email, password: password),
        "Authenticating with correct credentials should succeed."
      )
      // Make user inactive
      try user.requireVerification()
      XCTAssertNil(
        try User.authenticateUser(withEmail: email, password: password),
        "Authenticating inactive user should fail."
      )
    } catch let error {
      XCTFail("\(error)")
    }
  }

  func testVerification() {
    do {
      var user = try createTestUser()
      XCTAssertTrue(user.isActive, "User should be active")
      // Now make them require verification and reload
      try user.requireVerification()
      user = try User.get(withPk: user.pk)
      XCTAssertFalse(user.isActive, "User should be inactive")
      // Verify them and reload
      guard let code = user.verificationCode else {
        XCTFail()
        return
      }
      try user.verify(withCode: code)
      user = try User.get(withPk: user.pk)
      XCTAssertTrue(user.isActive, "User should be active")
    } catch let error {
      XCTFail("\(error)")
    }
  }

  func testRegenerateToken() {
    do {
      var user = try createTestUser()
      let oldToken = user.authToken
      let newTokenReturned = try user.regenerateToken()
      user = try User.get(withPk: user.pk)
      let newTokenRetrieved = user.authToken
      XCTAssertNotEqual(oldToken, newTokenReturned)
      XCTAssertNotEqual(oldToken, newTokenRetrieved)
      XCTAssertEqual(newTokenReturned, newTokenRetrieved)
    } catch let error {
      XCTFail("\(error)")
    }
  }

  func testEditProfile() {
    do {
      var user = try createTestUser()
      XCTAssertTrue(user.isActive, "User should be active")
      // Now edit profile fields, reload, and see if they change
      try user.editProfile(timezone: "Australia/Melbourne", language: "en-PIRAT", nickname: "Nicky", email: "e@mail.com")
      user = try User.get(withPk: user.pk)
      XCTAssertEqual(user.timezone, "Australia/Melbourne")
      XCTAssertEqual(user.language, "en-PIRAT")
      XCTAssertEqual(user.nickname, "Nicky")
      XCTAssertEqual(user.email, "e@mail.com")
    } catch let error {
      XCTFail("\(error)")
    }
  }

  func testChangePassword() {
    do {
      let email = "test@test.com"
      let user = try createTestUser(email: email, password: "password1")
      XCTAssertNotNil(
        try User.authenticateUser(withEmail: email, password: "password1")
      )
      // Fail to change the password
      do {
        try user.changePassword(from: "boggles", to: "password2")
      } catch User.Error.Forbidden {}
      // Change the password and re-authenticate
      try user.changePassword(from: "password1", to: "password2")
      XCTAssertNil(
        try User.authenticateUser(withEmail: email, password: "password1")
      )
      XCTAssertNotNil(
        try User.authenticateUser(withEmail: email, password: "password2")
      )
    } catch let error {
      XCTFail("\(error)")
    }
  }

}


extension UserTests {
  static var allTests : [(String, UserTests -> () throws -> Void)] {
    return [
      ("testAuthToken", testAuthToken),
      ("testAuthTokenStringValue", testAuthTokenStringValue),
      ("testInvalidAuthTokens", testInvalidAuthTokens),
      ("testGenerateAuthToken", testGenerateAuthToken),
      ("testGenerateUniqueAuthToken", testGenerateUniqueAuthToken),
      ("testCreateUser", testCreateUser),
      ("testSignupFlow", testSignupFlow),
      ("testAuthentication", testAuthentication),
      ("testVerification", testVerification),
      ("testRegenerateToken", testRegenerateToken),
      ("testEditProfile", testEditProfile),
      ("testChangePassword", testChangePassword),
    ]
  }
}
