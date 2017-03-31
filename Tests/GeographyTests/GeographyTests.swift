import XCTest
@testable import Geography

class GeographyTests: XCTestCase {

  static var allTests = [
    ("testCreateLocation", testCreateLocation),
  ]

  func testCreateLocation() {
    let root = Location(name: "ROOT", parent: nil)
    XCTAssertEqual(root.name, "ROOT")
  }

  func testCreateTree() {
    let root = Location(name: "ROOT", parent: nil)
    let node1 = Location(name: "NODE1", parent: root)
    let node2 = Location(name: "NODE2", parent: root)
    XCTAssertEqual(node1.name, "NODE1")
    XCTAssertEqual(node2.parent, root)
  }

}
