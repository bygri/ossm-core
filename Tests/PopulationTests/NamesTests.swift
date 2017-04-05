import XCTest
import Geography
import Random
@testable import Population

class NamesTests: XCTestCase {

  static var allTests = [
    ("testAddingNamesLists", testAddingNamesLists),
    ("testParentLocationNamesLists", testParentLocationNamesLists),
    ("testGenerateName", testGenerateName),
  ]

  func testAddingNamesLists() {
    let list1 = NamesList(firstNames: ["one"], lastNames: ["ONE"])
    let list2 = NamesList(firstNames: ["two"], lastNames: ["TWO"])
    let combined = list1 + list2
    XCTAssertEqual(combined.firstNames, ["one", "two"])
    XCTAssertEqual(combined.lastNames, ["ONE", "TWO"])
  }

  func testParentLocationNamesLists() throws {
    // Create the geography
    let root = Location(name: "ROOT", parent: nil)
    let leaf = Location(name: "LEAF", parent: root)
    // Create the generator
    let generator = NameGenerator(namesTable: [
      root: NamesList(firstNames: ["one"], lastNames: ["ONE"]),
      leaf: NamesList(firstNames: ["two"], lastNames: ["TWO"])
    ], randomGenerator: try URandom())
    // Get the concatenated list
    let combined = generator.namesList(for: leaf)
    XCTAssertEqual(combined.firstNames, ["two", "one"])
    XCTAssertEqual(combined.lastNames, ["TWO", "ONE"])
  }

  func testGenerateName() throws {
    // Create the geography
    let root = Location(name: "ROOT", parent: nil)
    // Create the generator
    let generator = NameGenerator(namesTable: [
      root: NamesList(
        firstNames: ["fred", "bob", "bill"],
        lastNames: ["smith"]
      ),
    ], randomGenerator: try URandom())
    // Generate a name
    let name = try generator.generate(for: root)
    print("Name: \(name)")
    XCTAssertTrue(["fred", "bob", "bill"].contains(name.first))
    XCTAssertEqual("smith", name.last)
  }

}
