import XCTest
@testable import OSSMCore

class GeographyTests: XCTestCase {

  static var allTests = [
    ("testCreateLocation", testCreateLocation),
    ("testCreateTree", testCreateTree),
    ("testAllParents", testAllParents),
    ("testTerminalChildren", testTerminalChildren),
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

  func testAllParents() {
    let root = Location(name: "ROOT", parent: nil)
    let node1 = Location(name: "NODE1", parent: root)
    let node2 = Location(name: "NODE2", parent: node1)
    let node3 = Location(name: "NODE3", parent: node2)
    XCTAssertEqual(node3.allParents, [node2, node1, root])
  }

  func testTerminalChildren() {
    let root = Location(name: "ROOT", parent: nil)
    let node1 = Location(name: "NODE1", parent: root) // terminal
    let node2 = Location(name: "NODE2", parent: root)
    let node21 = Location(name: "NODE2-1", parent: node2) // terminal
    let node22 = Location(name: "NODE2-2", parent: node2)
    let node221 = Location(name: "NODE2-2-1", parent: node22) // terminal
    let node222 = Location(name: "NODE2-2-2", parent: node22) // terminal
    let all = root.allTerminalChildren
    XCTAssertFalse(all.contains(root))
    XCTAssertTrue(all.contains(node1))
    XCTAssertFalse(all.contains(node2))
    XCTAssertTrue(all.contains(node21))
    XCTAssertFalse(all.contains(node22))
    XCTAssertTrue(all.contains(node221))
    XCTAssertTrue(all.contains(node222))
  }

}
