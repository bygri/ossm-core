import XCTest
@testable import OSSMCore


class DBTests: XCTestCase {

  override func setUp() {
    setLogLevel(.Debug)
  }

  func testPrepareDatabase() {
    prepareTestDatabase()
  }

}


extension DBTests {
  static var allTests : [(String, DBTests -> () throws -> Void)] {
    return [
      ("testPrepareDatabase", testPrepareDatabase),
    ]
  }
}
