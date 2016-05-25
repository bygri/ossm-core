import XCTest
@testable import ossmcore


class LocationTests: XCTestCase {

  override func setUp() {
    setLogLevel(.Debug)
  }

  func createTable(populate: Bool) {
    prepareTestDatabase()
    if populate { populateTable() }
  }
  
  func populateTable() {
    try! db().execute("INSERT INTO locations (pk, parent_pk, name) VALUES ( 1, NULL, 'World')")
    try! db().execute("INSERT INTO locations (pk, parent_pk, name) VALUES ( 2,  1, 'Oceania')")
    try! db().execute("INSERT INTO locations (pk, parent_pk, name) VALUES ( 3,    2, 'Australia')")
    try! db().execute("INSERT INTO locations (pk, parent_pk, name) VALUES ( 4,      3, 'New South Wales')")
    try! db().execute("INSERT INTO locations (pk, parent_pk, name) VALUES ( 5,        4, 'Sydney')")
    try! db().execute("INSERT INTO locations (pk, parent_pk, name) VALUES ( 6,        4, 'Blue Mountains')")
    try! db().execute("INSERT INTO locations (pk, parent_pk, name) VALUES ( 7,        4, 'Central Coast')")
    try! db().execute("INSERT INTO locations (pk, parent_pk, name) VALUES ( 8,        4, 'South Coast')")
    try! db().execute("INSERT INTO locations (pk, parent_pk, name) VALUES ( 9,      3, 'Victoria')")
    try! db().execute("INSERT INTO locations (pk, parent_pk, name) VALUES (10,        9, 'Melbourne')")
    try! db().execute("INSERT INTO locations (pk, parent_pk, name) VALUES (11,      3, 'Queensland')")
    try! db().execute("INSERT INTO locations (pk, parent_pk, name) VALUES (12,    2, 'New Zealand')")
    try! db().execute("INSERT INTO locations (pk, parent_pk, name) VALUES (13,  1, 'Europe')")
    try! db().execute("SELECT setval('locations_pk_seq', max(pk)) from locations") // reset PK
//     try! db().execute("INSERT INTO locations (pk, parent_pk, name) VALUES (x, y, 'z')")
  }

  func testSQLInsertInvalidLocation() {
    prepareTestDatabase()
    do {
      try db().execute("INSERT INTO locations (parent_pk, name) VALUES (99, 'Australia')")
      XCTFail()
    } catch { }
  }
  
  func testAddRootLocation() {
    prepareTestDatabase()
    XCTAssertNil(Location.getRoot())
    do {
      let root = try Location.addRoot(withName: "Mars")
      XCTAssertEqual(root?.name, "Mars")
      XCTAssertEqual(Location.getRoot()?.name, "Mars")
    } catch {
      XCTFail()
    }
    // Try adding a second one
    do {
      try Location.addRoot(withName: "Venus")
      XCTFail("Adding a second root should fail")
    } catch Location.Error.RootAlreadyExists {
      // Good stuff
    } catch {
      XCTFail("Wrong exception thrown")
    }
  }
  
  func testAddLocation() {
    prepareTestDatabase()
    populateTable()
    guard let rootLocation = Location.getRoot() else {
      XCTFail("No root location defined")
      return
    }
    let childCount = rootLocation.getChildren().count
    do {
      try rootLocation.insertChild(withName: "Asia")
    } catch let error {
      XCTFail("Insert child failed with \(error)")
    }
    XCTAssertEqual(rootLocation.getChildren().count, childCount+1)
  }
  
  func testAddDuplicateLocation() {
    prepareTestDatabase()
    populateTable()
    do {
      try db().execute("INSERT INTO locations (pk, parent_pk, name) VALUES ( 1, NULL, 'World')")
      try db().execute("INSERT INTO locations (pk, parent_pk, name) VALUES ( 2,  1, 'Oceania')")
      XCTFail("Should not succeed")
    } catch {}
  }

  func testFindRootLocation() {
    prepareTestDatabase()
    populateTable()
    XCTAssertEqual(Location.getRoot()?.name, "World")
  }

  func testFindNonExistentLocation() {
    prepareTestDatabase()
    populateTable()
    XCTAssertNil(Location.get(withPk: 99))
  }
  
  func testFindParent() {
    prepareTestDatabase()
    populateTable()
    let level4 = Location.get(withPk: 6)
    XCTAssertNotNil(level4)
    let level3 = level4?.getParent()
    XCTAssertEqual(level3?.name, "New South Wales")
    let level2 = level3?.getParent()
    XCTAssertEqual(level2?.name, "Australia")
    let level1 = level2?.getParent()
    XCTAssertEqual(level1?.name, "Oceania")
    let level0 = level1?.getParent()
    XCTAssertEqual(level0?.name, "World")
    XCTAssertNil(level0?.getParent())
  }
  
  func testFindParents() {
    prepareTestDatabase()
    populateTable()
    let location = Location.get(withPk: 10)
    XCTAssertNotNil(location)
    let parents = location?.getParents()
    guard let parentPks = parents?.map({ $0.pk }) else {
      XCTFail()
      return
    }
    XCTAssertEqual(parentPks, [9, 3, 2, 1], "Parent PKs should be the PK of each parent in reverse order.")
  }
  
  func testFindChildren() {
    prepareTestDatabase()
    populateTable()
    // Simple progression
    let level0 = Location.getRoot()
    XCTAssertEqual(level0?.name, "World")
    XCTAssertEqual(level0?.getChildren().count, 2)
    let level1 = level0?.getChildren().filter({ $0.name == "Oceania" }).first
    XCTAssertNotNil(level1)
    XCTAssertEqual(level1?.getChildren().count, 2)
    let level2 = level1?.getChildren().filter({ $0.name == "Australia" }).first
    XCTAssertNotNil(level2)
    XCTAssertEqual(level2?.getChildren().count, 3)
    let level3 = level2?.getChildren().filter({ $0.name == "New South Wales" }).first
    XCTAssertNotNil(level3)
    XCTAssertEqual(level3?.getChildren().count, 4)
    let level4 = level3?.getChildren().filter({ $0.name == "Sydney" }).first
    XCTAssertNotNil(level4)
    XCTAssertEqual(level4?.getChildren().count, 0)
    // Now try a bad one
    XCTAssertNil(level3?.getChildren().filter({ $0.name == "Europe" }).first)
  }

}


extension LocationTests {
  static var allTests : [(String, LocationTests -> () throws -> Void)] {
    return [
      ("testSQLInsertInvalidLocation", testSQLInsertInvalidLocation),
      ("testAddRootLocation", testAddRootLocation),
      ("testAddLocation", testAddLocation),
      ("testAddDuplicateLocation", testAddDuplicateLocation),
      ("testFindRootLocation", testFindRootLocation),
      ("testFindNonExistentLocation", testFindNonExistentLocation),
      ("testFindParent", testFindParent),
      ("testFindParents", testFindParents),
      ("testFindChildren", testFindChildren),
    ]
  }
}
