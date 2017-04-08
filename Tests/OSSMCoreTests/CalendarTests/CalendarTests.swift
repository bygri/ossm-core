import XCTest
@testable import OSSMCore

class CalendarTests: XCTestCase {

  static var allTests = [
    ("testDateInitWithSeconds", testDateInitWithSeconds),
  ]

  func testDateInitWithSeconds() {

    // init the date using seconds initialiser
    let date = Date(seconds: 100000000)

    // test that all values are correct
    XCTAssertEqual(date.year, 3)
    XCTAssertEqual(date.day, 62)
    XCTAssertEqual(date.hour, 9)
    XCTAssertEqual(date.minute, 46)
    XCTAssertEqual(date.second, 40)
  }

}
