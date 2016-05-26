import XCTest
@testable import ossmcore


class ClubTests: XCTestCase {

  override func setUp() {
    setLogLevel(.Debug)
  }

  func testAddClub() {
    prepareTestDatabase()
    do {
      let user: User = try User.create(withEmail: "test@test.com", password: "testpassword", authToken: User.AuthToken(string: "ABCDEFGHIJKLMNOPQRST")!, timezoneName: "Australia/Sydney", language: Language.Australian, isActive: true, nickname: "testuser", faceRecipe: "", accessLevel: User.AccessLevel.User)!
      let location: Location = try Location.addRoot(withName: "World")!
      let club = try Club.create(ofKind: Club.Kind.Private, forOwner: user, inLocation: location, withName: "Sports Group", badgeRecipe: "", primaryColour: "FF0000", secondaryColour: "00FF00", tertiaryColour: "0000FF")
      XCTAssertEqual(club?.name, "Sports Group")
    } catch let error {
      XCTFail()
    }
  }

}


extension ClubTests {
  static var allTests : [(String, ClubTests -> () throws -> Void)] {
    return [
      ("testAddClub", testAddClub),
    ]
  }
}
