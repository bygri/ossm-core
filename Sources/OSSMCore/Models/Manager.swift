import Fluent

public final class Manager: Entity {

  public var displayName: String
  public var email: String

  public let storage = Storage()

  public init(displayName: String, email: String) {
    self.displayName = displayName
    self.email = email
  }

  public init(row: Row) throws {
    displayName = try row.get("display_name")
    email = try row.get("email")
    id = try row.get(idKey)
  }

  public func makeRow() throws -> Row {
    var row = Row()
    try row.set("display_name", displayName)
    try row.set("email", email)
    try row.set(idKey, id)
    return row
  }

}


extension Manager: Preparation {

  public static func prepare(_ database: Fluent.Database) throws {
    try database.create(self) { t in
      t.id(for: self)
      t.string("display_name")
      t.string("email")
    }
  }

  public static func revert(_ database: Fluent.Database) throws {
    try database.delete(self)
  }

}


extension Manager: Equatable {
  public static func == (lhs: Manager, rhs: Manager) -> Bool {
    if let lhsId = lhs.id, let rhsId = rhs.id {
      return lhsId == rhsId
    }
    return lhs === rhs
  }
}
