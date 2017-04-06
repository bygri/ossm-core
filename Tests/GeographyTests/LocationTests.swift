import XCTest
@testable import Geography

class LocationTests: XCTestCase {

  static var allTests = [
    ("testCreateLocation", testCreateLocation),
    ("testCreateTree", testCreateTree),
    ("testAllParents", testAllParents),
    ("testTerminalChildren", testTerminalChildren),
    ("testLookupLocation", testLookupLocation),
  ]

  func testCreateLocation() throws {
    let root = try Location(id: 0, name: "ROOT")
    XCTAssertEqual(root.name, "ROOT")
  }

  func testCreateTree() throws {
    let node1 = try Location(id: 1, name: "NODE1")
    let node2 = try Location(id: 2, name: "NODE2")
    let root = try Location(id: 0, name: "ROOT", children: [
      node1, node2
    ])
    XCTAssertEqual(node1.name, "NODE1")
    XCTAssertEqual(node2.parent, root)
  }

  func testAllParents() throws {
    let node3 = try Location(id: 3, name: "NODE3")
    let node2 = try Location(id: 2, name: "NODE2", children: [node3])
    let node1 = try Location(id: 1, name: "NODE1", children: [node2])
    let root = try Location(id: 0, name: "ROOT", children: [node1])
    XCTAssertEqual(node3.allParents, [node2, node1, root])
  }

  func testTerminalChildren() throws {
    let node222 = try Location(id: 6, name: "NODE222")
    let node221 = try Location(id: 5, name: "NODE221")
    let node22 = try Location(id: 4, name: "NODE22", children: [node221, node222])
    let node21 = try Location(id: 3, name: "NODE21")
    let node2 = try Location(id: 2, name: "NODE2", children: [node21, node22])
    let node1 = try Location(id: 1, name: "NODE1")
    let root = try Location(id: 0, name: "ROOT", children: [node1, node2])
    let all = root.allTerminalChildren
    XCTAssertFalse(all.contains(root))
    XCTAssertTrue(all.contains(node1))
    XCTAssertFalse(all.contains(node2))
    XCTAssertTrue(all.contains(node21))
    XCTAssertFalse(all.contains(node22))
    XCTAssertTrue(all.contains(node221))
    XCTAssertTrue(all.contains(node222))
  }

  func testLookupLocation() throws {
    let rootLocation = try Location(id: 0, name: "ROOT", children: [
        Location(id: 1, name: "1", children: [
          Location(id: 2, name: "1-1"),
          Location(id: 3, name: "1-2"),
        ]),
        Location(id: 4, name: "2", children: [
          Location(id: 5, name: "2-1"),
        ])
    ])
    try Location.buildIndex(fromRoot: rootLocation)
    XCTAssertEqual(try Location.fetch(at: 3).name, "1-2")
    do {
      let _ = try Location.fetch(at: 99)
      XCTFail("No error thrown")
    } catch Location.Error.locationIdDoesNotExist {
    } catch {
      XCTFail("Wrong error thrown")
    }
  }

}
