import XCTest
import Fluent
@testable import OSSMCore

class SimTests: XCTestCase {

  static var allTests = [
    ("testInMemoryDatabase", testInMemoryDatabase),
  ]

  func testInMemoryDatabase() throws {
    let driver = try MemoryDriver()
    let database = Database(driver)
    try Sim.prepare(database)
    // Create a sim
    let sim = Sim(firstName: "first", lastName: "last", nickName: "nick", birthDate: Date(seconds: 0),
                birthLocation: try Location(id: 1, name: "birth"), location: try Location(id: 2, name: "current"),
                leadership: 5, agility: 5, fame: 5)
    try sim.save()
    // Fetch again
    guard let id = sim.id, let fetched = try Sim.find(id) else {
      XCTFail()
      return
    }
    XCTAssertEqual(fetched.firstName, "first")
    XCTAssertEqual(fetched.lastName, "last")
    XCTAssertEqual(fetched.nickName, "nick")
    XCTAssertEqual(fetched.leadership, 5)
    XCTAssertEqual(fetched.agility, 5)
    XCTAssertEqual(fetched.fame, 5)
  }

}
