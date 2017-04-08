import XCTest
@testable import OSSMCore

class CalendarTests: XCTestCase {

  static var allTests = [
    ("testDateInitWithSeconds", testDateInitWithSeconds),
    ("testDateConvertToSeconds", testDateConvertToSeconds),
  ]

  // NOTE: this test will start failing if we change the value of daysPerYear in Date struct
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

  // NOTE: this test will start failing if we change the value of daysPerYear in Date struct
  func testDateConvertToSeconds() {

    // init the date using regular initialiser
    let date = Date(year: 3, day: 62, hour: 9, minute: 46, second: 41)

    // test that seconds value is correct
    XCTAssertEqual(date.toSeconds(), 100000001)
  }

}
