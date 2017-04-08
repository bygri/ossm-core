import XCTest
import Fluent
@testable import OSSMCore

class ClubTests: XCTestCase {

  static var allTests = [
    ("testInMemoryDatabase", testInMemoryDatabase),
  ]

  func testInMemoryDatabase() throws {
    let driver = try MemoryDriver()
    let database = Database(driver)
    try Club.prepare(database)
    try Manager.prepare(database)
    // Create a club
    let location = try Location(id: 0, name: "location")
    try Location.buildIndex(fromRoot: location)
    let manager = Manager(displayName: "manager", email: "email@email.com")
    try manager.save()
    let club = Club(displayName: "club1", managerId: manager.id!, locationId: 0, primaryColor: try Color("FFFFFF"), secondaryColor: try Color("FFFFFF"), tertiaryColor: try Color("FFFFFF"))
    try club.save()
    // Fetch again
    guard let id = club.id, let fetched = try Club.find(id) else {
      XCTFail()
      return
    }
    XCTAssertEqual(fetched.displayName, "club1")
    // Get manager
    XCTAssertEqual(try fetched.manager().get()?.displayName, "manager")
  }

}
