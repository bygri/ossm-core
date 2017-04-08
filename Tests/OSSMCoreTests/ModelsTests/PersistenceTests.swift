import XCTest
import Fluent
@testable import OSSMCore

class PersistenceTests: XCTestCase {

  static var allTests = [
    ("testInMemoryDatabase", testInMemoryDatabase),
  ]

  func testInMemoryDatabase() throws {
    let driver = try MemoryDriver()
    let database = Database(driver)
    try TestEntity.prepare(database)
    // Create an entity
    let saved = TestEntity(name: "peter")
    XCTAssertNil(saved.id)
    try saved.save()
    guard let id = saved.id else {
      XCTFail()
      return
    }
    // Get the entity
    guard let fetched = try TestEntity.find(id) else {
      XCTFail()
      return
    }
    // Check for equality
    XCTAssertEqual(fetched.name, "peter")
    XCTAssertEqual(fetched, saved)
  }

}

fileprivate final class TestEntity: Entity, Preparation, Equatable {
  var name: String
  let storage = Storage()

  init(name: String) {
    self.name = name
  }

  init(row: Row) throws {
    name = try row.get("name")
  }

  func makeRow() throws -> Row {
    var row = Row()
    try row.set("name", name)
    return row
  }

  static func prepare(_ database: Fluent.Database) throws {
    try database.create(self) { t in
      t.id(for: self)
      t.string("name")
    }
  }

  static func revert(_ database: Fluent.Database) throws {
    try database.delete(self)
  }

  public static func == (lhs: TestEntity, rhs: TestEntity) -> Bool {
    if let lhsId = lhs.id, let rhsId = rhs.id {
      return lhsId == rhsId
    }
    return lhs === rhs
  }
}
