import Fluent

public final class Club: Entity {

  public var displayName: String

  public var managerId: Identifier
  public var locationId: Int

  public var primaryColor: Color
  public var secondaryColor: Color
  public var tertiaryColor: Color

  public let storage = Storage()

  public func manager() throws -> Parent<Club, Manager> {
    return parent(id: managerId)
  }

  public func location() throws -> Location {
    guard let loc = try Location.find(locationId) else {
      throw Location.Error.notFound(locationId)
    }
    return loc
  }

  public init(
    displayName: String,
    managerId: Identifier,
    locationId: Int,
    primaryColor: Color,
    secondaryColor: Color,
    tertiaryColor: Color
  ) {
    self.displayName = displayName
    self.managerId = managerId
    self.locationId = locationId
    self.primaryColor = primaryColor
    self.secondaryColor = secondaryColor
    self.tertiaryColor = tertiaryColor
  }

  public init(row: Row) throws {
    displayName = try row.get("display_name")
    managerId = try row.get("manager_id")
    locationId = try row.get("location_id")
    primaryColor = try row.get("primary_color")
    secondaryColor = try row.get("secondary_color")
    tertiaryColor = try row.get("tertiary_color")
    id = try row.get(idKey)
  }

  public func makeRow() throws -> Row {
    var row = Row()
    try row.set("display_name", displayName)
    try row.set("manager_id", managerId)
    try row.set("location_id", locationId)
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
      t.id()
      t.string("display_name")
      t.foreignId(for: Manager.self)
      t.int("location_id")
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
