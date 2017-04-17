import XCTest
@testable import OSSMCore

class ColorTests: XCTestCase {

  static var allTests = [
    ("testCreateFromHexValue", testCreateFromHexValue),
  ]

  func testCreateFromHexValue() throws {
    // Valid hex value
    let _ = try Color("FFFFFF")
    // Invalid hex value
    do {
      let _ = try Color("XYZABC")
      XCTFail()
    } catch Color.Error.invalidHexString {
    } catch {
      XCTFail()
    }
    // Too long
    do {
      let _ = try Color("ABCDEFGHIJKL")
      XCTFail()
    } catch Color.Error.invalidHexString {
    } catch {
      XCTFail()
    }
    // Too short
    do {
      let _ = try Color("123")
      XCTFail()
    } catch Color.Error.invalidHexString {
    } catch {
      XCTFail()
    }
  }

}
