import Foundation
import XCTest
@testable import OSSMCore


class UserTests: XCTestCase {

  override func setUp() {
    setLogLevel(.Debug)
    prepareTestDatabase()
  }

  func testAuthToken() {
    // Init with a valid token string
    XCTAssertNotNil(
      User.AuthToken(string: "ABCDEFabcdef12345600"),
      "The token should be valid."
    )
  }

  func testAuthTokenStringValue() {
    // Test conversion to and from a token string
    let string = "ABCDEFabcdef12345600"
    guard let token = User.AuthToken(string: string) else {
      XCTFail("The token should be valid.")
      return
    }
    XCTAssertEqual(string, token.stringValue)
  }

  func testInvalidAuthTokens() {
    // Try initing with invalid token strings
    XCTAssertNil(
      User.AuthToken(string: "too short"),
      "A short token string should be invalid."
    )
    XCTAssertNil(
      User.AuthToken(string: "too long long long far too long"),
      "A long token string should be invalid."
    )
    XCTAssertNil(
      User.AuthToken(string: "inv@lid character$"),
      "A token string should not contain invalid characters."
    )
  }

  func testGenerateAuthToken() {
    XCTAssertNotNil(User.AuthToken.generate())
  }

  func testGenerateUniqueAuthToken() {
    XCTAssertNotNil(try? User.AuthToken.generateUnique())
  }

  func testCreateUser() {
    do {
      let generatedToken = try User.AuthToken.generateUnique()
      let now = NSDate()
      let createdUser = try User.create(
        withEmail: "test@test.com",
        password: "password",
        authToken: generatedToken,
        verificationCode: nil,
        isActive: true,
        accessLevel: User.AccessLevel.User,
        nickname: "testuser",
        timezoneName: "Australia/Sydney",
        language: Language.Australian,
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
      XCTAssertEqual(user.timezoneName, "Australia/Sydney")
      XCTAssertEqual(user.language, Language.Australian)
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
        timezoneName: "Australia/Sydney",
        language: Language.Australian,
        nickname: "testuser")
      guard let verificationCode = user.verificationCode else {
        XCTFail("A verification code should have been generated.")
        return
      }
      // Attempt authentication - should fail.
      XCTAssertFalse(
        try User.authenticateUser(email: email, password: password),
        "Authenticating an inactive user should fail."
      )
      // Attempt authentication with incorrect credentials - should fail
      XCTAssertFalse(
        try User.authenticateUser(email: email, password: "thisisnotyourpassword"),
        "Authenticating an inactive user with incorrect credentials should fail."
      )
      // Verify with an incorrect code.
      XCTAssertFalse(
        try user.verify(withCode: "NOTREALLYACODE"),
        "Verifying a user with an incorrect code should fail."
      )
      // Attempt authentication - should fail.
      XCTAssertFalse(
        try User.authenticateUser(email: email, password: password),
        "Authenticating an inactive user who was then verified incorrectly should fail."
      )
      // Verify with a correct code
      XCTAssertTrue(
        try user.verify(withCode: verificationCode),
        "Verifying a user with a correct code should succeed."
      )
      // Attempt authentication with incorrect credentials - should fail
      XCTAssertFalse(
        try User.authenticateUser(email: email, password: "thisisnotyourpassword"),
        "Authenticating an active user with incorrect credentials should fail."
      )
      // Attempt authentication - should succeed.
      print("pw \(password)")
      XCTAssertTrue(
        try User.authenticateUser(email: email, password: password),
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
      let user = try User.create(
        withEmail: email,
        password: password,
        authToken: try User.AuthToken.generateUnique(),
        verificationCode: nil,
        isActive: true,
        accessLevel: User.AccessLevel.User,
        nickname: "testuser",
        timezoneName: "Australia/Sydney",
        language: Language.Australian,
        faceRecipe: "",
        dateCreated: NSDate(),
        lastLogin: nil
      )
      // Try authentication
      XCTAssertFalse(
        try User.authenticateUser(email: "notyouremail@email.com", password: password),
        "Authenticating with incorrect email should fail."
      )
      XCTAssertFalse(
        try User.authenticateUser(email: email, password: "not your password"),
        "Authenticating with incorrect password should fail."
      )
      XCTAssertTrue(
        try User.authenticateUser(email: email, password: password),
        "Authenticating with correct credentials should succeed."
      )
      // Make user inactive
      try user.requireVerification()
      XCTAssertFalse(
        try User.authenticateUser(email: email, password: password),
        "Authenticating inactive user should fail."
      )
    } catch let error {
      XCTFail("\(error)")
    }
  }

  func testVerification() {
    do {
      // Create an active user.
      let email = "test@test.com"
      let password = "apassword"
      var user = try User.create(
        withEmail: email,
        password: password,
        authToken: try User.AuthToken.generateUnique(),
        verificationCode: nil,
        isActive: true,
        accessLevel: User.AccessLevel.User,
        nickname: "testuser",
        timezoneName: "Australia/Sydney",
        language: Language.Australian,
        faceRecipe: "",
        dateCreated: NSDate(),
        lastLogin: nil
      )
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
    ]
  }
}
