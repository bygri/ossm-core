import XCTest
@testable import ossmcore


class LocationTests: XCTestCase {

  override func setUp() {
    setLogLevel(.Debug)
    try! configureDatabase(host: "127.0.0.1", port: 5432, username: "ossm", password: "abracadabra", databaseName: "ossm-test")
    try! db().execute("DROP TABLE IF EXISTS locations")
    try! db().execute("CREATE TABLE locations (l1 smallint, l2 smallint, l3 smallint, l4 smallint, name varchar(40) not null)")
    try! db().execute("CREATE INDEX locations_key ON locations (l1, l2, l3, l4)")
    try! db().execute("INSERT INTO locations (l1, l2, l3, l4, name) VALUES ( 1, NULL, NULL, NULL, 'Oceania')")
    try! db().execute("INSERT INTO locations (l1, l2, l3, l4, name) VALUES ( 1,    1, NULL, NULL, 'Australia')")
    try! db().execute("INSERT INTO locations (l1, l2, l3, l4, name) VALUES ( 1,    1,    1, NULL, 'New South Wales')")
    try! db().execute("INSERT INTO locations (l1, l2, l3, l4, name) VALUES ( 1,    1,    1,    1, 'Sydney')")
    try! db().execute("INSERT INTO locations (l1, l2, l3, l4, name) VALUES ( 1,    1,    1,    2, 'Blue Mountains')")
    try! db().execute("INSERT INTO locations (l1, l2, l3, l4, name) VALUES ( 1,    1,    2, NULL, 'Victoria')")
    try! db().execute("INSERT INTO locations (l1, l2, l3, l4, name) VALUES ( 1,    1,    2,    1, 'Melbourne')")
    try! db().execute("INSERT INTO locations (l1, l2, l3, l4, name) VALUES ( 1,    2, NULL, NULL, 'New Zealand')")
  }

  func testFindLevel1Location() {
    XCTAssertEqual(Location.get(1,nil,nil,nil)?.name, "Oceania")
  }

  func testFindLevel2Location() {
    XCTAssertEqual(Location.get(1,2,nil,nil)?.name, "New Zealand")
  }

  func testFindLevel3Location() {
    XCTAssertEqual(Location.get(1,1,2,nil)?.name, "Victoria")
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
    XCTAssertNil(Location.get(99,nil,nil,nil))
  }

}

extension LocationTests {
  static var allTests : [(String, LocationTests -> () throws -> Void)] {
    return [
      ("testFindLevel1Location", testFindLevel1Location),
      ("testFindLevel2Location", testFindLevel2Location),
      ("testFindLevel3Location", testFindLevel3Location),
      ("testFindLevel4Location", testFindLevel4Location),
      ("testFindInvalidLocation", testFindInvalidLocation),
      ("testFindNonExistentLocation", testFindNonExistentLocation),
    ]
  }
}
