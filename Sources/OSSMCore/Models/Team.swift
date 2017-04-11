import Fluent

public final class Team: Entity {

  public enum TeamType {
    /// Club teams are owned by a club and are managed by the
    /// club's manager. Players may be assigned from the club's
    /// player roster.
    case club
    /// Representative teams (e.g. national teams) do not have
    /// a club. They are managed by a head coach and potentially
    /// assistant coaches. Players may be assigned from the team's
    /// location.
    case representative
  }

  /// Name of the team.
  public var displayName: String

  /// Club teams must have a clubId or they are a bot team.
  /// Representative teams may not have a clubId.
  /// To find the owner of a representative team, use
  /// ManagerTeamAccess.
  public var clubId: Identifier?

  /// The team's home location. Particularly important for
  /// representative teams, as only players born in this location
  /// may play in the team.
  public var locationId: Int

  public let storage = Storage()

  public init(
    displayName: String,
    clubId: Identifier?,
    locationId: Int
  ) {
    self.displayName = displayName
    self.clubId = clubId
    self.locationId = locationId
  }

  public init(row: Row) throws {
    displayName = try row.get("display_name")
    clubId = try row.get("club_id")
    locationId = try row.get("location_id")
  }

  public func makeRow() throws -> Row {
    var row = Row()
    try row.set("display_name", displayName)
    try row.set("club_id", clubId)
    try row.set("location_id", locationId)
    try row.set(idKey, id)
    return row
  }

}

extension Team: Preparation {

  public static func prepare(_ database: Fluent.Database) throws {
    try database.create(self) { t in
      t.id(for: self)
      t.string("display_name")
      t.foreignId(for: Club.self)
      t.int("location_id")
    }
  }

  public static func revert(_ database: Fluent.Database) throws {
    try database.delete(self)
  }

}

extension Team: Equatable {
  public static func == (lhs: Team, rhs: Team) -> Bool {
    if let lhsId = lhs.id, let rhsId = rhs.id {
      return lhsId == rhsId
    }
    return lhs === rhs
  }
}
