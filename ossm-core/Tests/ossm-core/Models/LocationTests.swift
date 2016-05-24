import XCTest
@testable import ossmcore


class LocationTests: XCTestCase {

  override func setUp() {
    setLogLevel(.Debug)
    try! configureDatabase(host: "127.0.0.1", port: 5432, username: "ossm", password: "abracadabra", databaseName: "ossm-test")
    try! db().execute("DROP TABLE IF EXISTS locations")
    try! db().execute("CREATE TABLE locations (l1 smallint, l2 smallint, l3 smallint, l4 smallint, name varchar(40) not null)")
    try! db().execute("CREATE UNIQUE INDEX locations_key ON locations (l1, l2, l3, l4)")
    try! db().execute("INSERT INTO locations (l1, l2, l3, l4, name) VALUES ( NULL, NULL, NULL, NULL, 'World')")
    try! db().execute("INSERT INTO locations (l1, l2, l3, l4, name) VALUES (    1, NULL, NULL, NULL, 'Oceania')")
    try! db().execute("INSERT INTO locations (l1, l2, l3, l4, name) VALUES (    1,    1, NULL, NULL, 'Australia')")
    try! db().execute("INSERT INTO locations (l1, l2, l3, l4, name) VALUES (    1,    1,    1, NULL, 'New South Wales')")
    try! db().execute("INSERT INTO locations (l1, l2, l3, l4, name) VALUES (    1,    1,    1,    1, 'Sydney')")
    try! db().execute("INSERT INTO locations (l1, l2, l3, l4, name) VALUES (    1,    1,    1,    2, 'Blue Mountains')")
    try! db().execute("INSERT INTO locations (l1, l2, l3, l4, name) VALUES (    1,    1,    1,    3, 'Central Coast')")
    try! db().execute("INSERT INTO locations (l1, l2, l3, l4, name) VALUES (    1,    1,    1,    4, 'South Coast')")
    try! db().execute("INSERT INTO locations (l1, l2, l3, l4, name) VALUES (    1,    1,    2, NULL, 'Victoria')")
    try! db().execute("INSERT INTO locations (l1, l2, l3, l4, name) VALUES (    1,    1,    2,    1, 'Melbourne')")
    try! db().execute("INSERT INTO locations (l1, l2, l3, l4, name) VALUES (    1,    1,    3, NULL, 'Queensland')")
    try! db().execute("INSERT INTO locations (l1, l2, l3, l4, name) VALUES (    1,    2, NULL, NULL, 'New Zealand')")
  }
  
  func testAddDuplicateLocation() {
    XCTAssertNil(try? db().execute("INSERT INTO locations (l1, l2, l3, l4, name) VALUES ( NULL, NULL, NULL, NULL, 'World2')"))
    XCTAssertNil(try? db().execute("INSERT INTO locations (l1, l2, l3, l4, name) VALUES ( 1, NULL, NULL, NULL, 'Oceania2')"))
  }
  
  func testFindlevel0Location() {
    XCTAssertEqual(Location.get(nil)?.name, "World")
  }

  func testFindLevel1Location() {
    XCTAssertEqual(Location.get(1)?.name, "Oceania")
  }

  func testFindLevel2Location() {
    XCTAssertEqual(Location.get(1,2)?.name, "New Zealand")
  }

  func testFindLevel3Location() {
    XCTAssertEqual(Location.get(1,1,2)?.name, "Victoria")
  }

  func testFindLevel4Location() {
    XCTAssertEqual(Location.get(1,1,1,2)?.name, "Blue Mountains")
  }

  func testFindInvalidLocation() {
    XCTAssertNil(Location.get(9,nil,nil,  9))
    XCTAssertNil(Location.get(9,  9,nil,  9))
    XCTAssertNil(Location.get(9,nil,  9,nil))
    XCTAssertNil(Location.get(9,nil,  9,  9))
  }

  func testFindNonExistentLocation() {
    XCTAssertNil(Location.get(99))
  }
  
  func testFindParent() {
    let level4 = Location.get(1,1,1,2)
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
  
  func testFindChildren() {
    let level0 = Location.get(nil)
    XCTAssertEqual(level0?.name, "World")
    XCTAssertEqual(level0?.getChildren().count, 1)
    let level1 = level0?.getChildren().first
    XCTAssertEqual(level1?.name, "Oceania")
    XCTAssertEqual(level1?.getChildren().count, 2)
    let level2 = level1?.getChildren().first
    XCTAssertEqual(level2?.name, "Australia")
    XCTAssertEqual(level2?.getChildren().count, 3)
    let level3 = level2?.getChildren().first
    XCTAssertEqual(level3?.name, "New South Wales")
    XCTAssertEqual(level3?.getChildren().count, 4)
    let level4 = level3?.getChildren().first
    XCTAssertEqual(level4?.name, "Sydney")
    XCTAssertEqual(level4?.getChildren().count, 0)
  }

}


extension LocationTests {
  static var allTests : [(String, LocationTests -> () throws -> Void)] {
    return [
      ("testAddDuplicateLocation", testAddDuplicateLocation),
      ("testFindLevel1Location", testFindLevel1Location),
      ("testFindLevel2Location", testFindLevel2Location),
      ("testFindLevel3Location", testFindLevel3Location),
      ("testFindLevel4Location", testFindLevel4Location),
      ("testFindInvalidLocation", testFindInvalidLocation),
      ("testFindNonExistentLocation", testFindNonExistentLocation),
      ("testFindParent", testFindParent),
      ("testFindChildren", testFindChildren),
    ]
  }
}
