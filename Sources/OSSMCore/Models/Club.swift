import Fluent

public final class Club: Entity {

  public var displayName: String

  public var manager: Manager
  // public var location: Location

  public var primaryColor: Color
  public var secondaryColor: Color
  public var tertiaryColor: Color

  public let storage = Storage()

  public init(
    displayName: String,
    manager: Manager,
    // location: Location,
    primaryColor: Color,
    secondaryColor: Color,
    tertiaryColor: Color
  ) {
    self.displayName = displayName
    self.manager = manager
    // self.location = location
    self.primaryColor = primaryColor
    self.secondaryColor = secondaryColor
    self.tertiaryColor = tertiaryColor
  }

  public init(row: Row) throws {
    displayName = try row.get("display_name")
    manager = try Manager.find(row.get("manager_id") as Int)!
    // location = try Location.find(row.get("location_id"))
    primaryColor = try row.get("primary_color")
    secondaryColor = try row.get("secondary_color")
    tertiaryColor = try row.get("tertiary_color")
    id = try row.get(idKey)
  }

  public func makeRow() throws -> Row {
    var row = Row()
    try row.set("display_name", displayName)
    try row.set("manager_id", manager.id)
    // try row.set("location_id", location)
    try row.set("primary_color", primaryColor)
    try row.set("secondary_color", secondaryColor)
    try row.set("tertiary_color", tertiaryColor)
    try row.set(idKey, id)
    return row
  }

}


extension Club: Preparation {

  public static func prepare(_ database: Fluent.Database) throws {
    try database.create(self) { t in
      t.id(for: self)
      t.string("display_name")
      t.foreignId(for: Manager.self)
      // t.int("location_id")
      t.string("primary_color", length: 6)
      t.string("secondary_color", length: 6)
      t.string("tertiary_color", length: 6)
    }
  }

  public static func revert(_ database: Fluent.Database) throws {
    try database.delete(self)
  }

}


extension Club: Equatable {
  public static func == (lhs: Club, rhs: Club) -> Bool {
    if let lhsId = lhs.id, let rhsId = rhs.id {
      return lhsId == rhsId
    }
    return lhs === rhs
  }
}
