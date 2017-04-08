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
    let manager = Manager(displayName: "manager", email: "email@email.com")
    try manager.save()
    let club = Club(displayName: "club1", manager: manager, primaryColor: try Color("FFFFFF"), secondaryColor: try Color("FFFFFF"), tertiaryColor: try Color("FFFFFF"))
    try club.save()
    // Fetch again
    guard let id = club.id, let fetched = try Club.find(id) else {
      XCTFail()
      return
    }
    XCTAssertEqual(fetched.displayName, "club1")
    // Get manager
    XCTAssertEqual(fetched.manager.displayName, "manager")
  }

}
