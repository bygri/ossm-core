import Foundation
import XCTest
@testable import OSSMCore


class ClubTests: XCTestCase {

  override func setUp() {
    setLogLevel(.Debug)
  }

  func testAddClub() {
    prepareTestDatabase()
    do {
      let user = try User.create(
        withEmail: "test@test.com",
        password: "password",
        authToken: User.AuthToken.generate(),
        verificationCode: nil,
        isActive: true,
        accessLevel: User.AccessLevel.User,
        nickname: "testuser",
        timezoneName: "Australia/Sydney",
        language: Language.Australian,
        faceRecipe: "",
        dateCreated: NSDate(),
        lastLogin: nil
      )
      let location: Location = try Location.addRoot(withName: "World")!
      let club = try Club.create(ofKind: Club.Kind.Private, forOwner: user, inLocation: location, withName: "Sports Group", badgeRecipe: "", primaryColour: "FF0000", secondaryColour: "00FF00", tertiaryColour: "0000FF")
      XCTAssertEqual(club?.name, "Sports Group")
    } catch let error {
      XCTFail("\(error)")
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
