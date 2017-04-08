import Fluent

public final class Sim: Entity {

  public var firstName: String
  public var lastName: String
  public var nickName: String?
  // public var birthLocation: Location
  // public var location: Location

  // simple attributes
  public var leadership: Int
  public var agility: Int
  public var fame: Int

  public let storage = Storage()

  public init(firstName: String, lastName: String, nickName: String?,
              birthLocation: Location, location: Location, leadership: Int, agility: Int,
              fame: Int) {
    self.firstName = firstName
    self.lastName = lastName
    self.nickName = nickName
    // self.birthLocation = birthLocation
    // self.location = location
    self.leadership = leadership
    self.agility = agility
    self.fame = fame
  }

  public init(row: Row) throws {
    firstName = try row.get("first_name")
    lastName = try row.get("last_name")
    nickName = try row.get("nick_name")
    // birthLocation = try Location.find(row.get("birth_location_id"))
    // location = try Location.find(row.get("location_id"))
    leadership = try row.get("leadership")
    agility = try row.get("agility")
    fame = try row.get("fame")
    id = try row.get(idKey)
  }

  public func makeRow() throws -> Row {
    var row = Row()
    try row.set("first_name", firstName)
    try row.set("last_name", lastName)
    try row.set("nick_name", nickName)
    // try row.set("birth_location_id", birthLocation.id)
    // try row.set("location_id", location.id)
    try row.set("leadership", leadership)
    try row.set("agility", agility)
    try row.set("fame", fame)
    try row.set(idKey, id)
    return row
  }

}

extension Sim: Preparation {

  public static func prepare(_ database: Fluent.Database) throws {
    try database.create(self) { t in
      t.id(for: self)
      t.string("first_name")
      t.string("last_name")
      t.string("nick_name")
      // t.int("birth_location_id")
      // t.int("location_id")
      t.int("leadership")
      t.int("agility")
      t.int("fame")
    }
  }

  public static func revert(_ database: Fluent.Database) throws {
    try database.delete(self)
  }

}


extension Sim: Equatable {
  public static func == (lhs: Sim, rhs: Sim) -> Bool {
    if let lhsId = lhs.id, let rhsId = rhs.id {
      return lhsId == rhsId
    }
    return lhs === rhs
  }
}
