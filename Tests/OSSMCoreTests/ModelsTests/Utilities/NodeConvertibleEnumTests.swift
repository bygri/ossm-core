import XCTest
@testable import OSSMCore

class NodeConvertibleEnumTests: XCTestCase {

  static var allTests = [
    ("testNodeConversion", testNodeConversion),
  ]

  enum TestEnum: Int, NodeConvertibleEnum {
    case myCase
  }

  func testNodeConversion() throws {
    let preConversion = TestEnum.myCase
    let node = try preConversion.makeNode(in: nil)
    let postConversion: TestEnum = try TestEnum(node: node)
    XCTAssertEqual(preConversion, postConversion)
  }

}
