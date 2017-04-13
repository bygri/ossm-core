import Fluent

/**
  Controls the level of access a manager has to a team
  which is not normally part of a club.

  Used for:
  - representative teams
  - 'mentor' access
*/
public final class ManagerTeamAccess: Entity {

  /// Details on these types of access are TBD.
  public enum AccessType: Int, NodeConvertibleEnum {
    case observer = 1
    case assistantCoach = 2
    case headCoach = 3
  }

  public var managerId: Identifier
  public var teamId: Identifier
  public var accessType: AccessType

  public let storage = Storage()

  public func manager() throws -> Parent<ManagerTeamAccess, Manager> {
    return parent(id: managerId)
  }

  public func team() throws -> Parent<ManagerTeamAccess, Team> {
    return parent(id: teamId)
  }

  public init(
    managerId: Identifier,
    teamId: Identifier,
    accessType: AccessType
  ) {
    self.managerId = managerId
    self.teamId = teamId
    self.accessType = accessType
  }

  public init(row: Row) throws {
    managerId = try row.get("manager_id")
    teamId = try row.get("team_id")
    accessType = try row.get("access_type")
  }

  public func makeRow() throws -> Row {
    var row = Row()
    try row.set("manager_id", managerId)
    try row.set("team_id", teamId)
    try row.set("access_type", accessType)
    try row.set(idKey, id)
    return row
  }

}

extension ManagerTeamAccess: Preparation {

  public static func prepare(_ database: Fluent.Database) throws {
    try database.create(self) { t in
      t.id(for: self)
      t.foreignId(for: Manager.self)
      t.foreignId(for: Team.self)
      t.int("access_type")
    }
  }

  public static func revert(_ database: Fluent.Database) throws {
    try database.delete(self)
  }

}
