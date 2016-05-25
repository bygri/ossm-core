import XCTest
@testable import ossmcore


class UserTests: XCTestCase {

  override func setUp() {
    setLogLevel(.Debug)
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

}

extension UserTests {
  static var allTests : [(String, UserTests -> () throws -> Void)] {
    return [
      ("testAuthToken", testAuthToken),
      ("testAuthTokenStringValue", testAuthTokenStringValue),
      ("testInvalidAuthTokens", testInvalidAuthTokens),
    ]
  }
}
