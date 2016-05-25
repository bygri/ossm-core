import Foundation
import SQL
import PostgreSQL

/**
CREATE TABLE "locations" (
  "pk" serial NOT NULL PRIMARY KEY,
  "parent_pk" INT,
  "name" varchar(40) NOT NULL
);
*/

public struct Location {
  
  public let pk: Int
  let parentPk: Int?
  public let name: String
  
  public init(pk: Int, parentPk: Int?, name: String) {
    self.pk = pk
    self.parentPk = parentPk
    self.name = name
  }
  
}


extension Location {
  
  public init?(row: Row) {
    do {
      guard let
        pk: Int = try row.value("pk"),
        name: String = try row.value("name")
      else {
        return nil
      }
      self.init(pk: pk, parentPk: try? row.value("parent_pk"), name: name)
    } catch let error {
      log("Init error: \(error)", level: .Error)
      return nil
    }
  }
  
  public static func getRoot() -> Location? {
    do {
      let rows = try db().execute("SELECT * FROM locations WHERE parent_pk IS NULL")
      if let
        row = rows.first,
        location = Location(row: row)
      {
        return location
      }
    } catch {
      log("SQL error: \(db().mostRecentError)")
    }
    return nil
  }

  
  public static func get(withPk pk: Int) -> Location? {
    do {
      let rows = try db().execute("SELECT * FROM locations WHERE pk = %@", parameters: pk)
      if let
        row = rows.first,
        location = Location(row: row)
      {
        return location
      }
    } catch {
      log("SQL error: \(db().mostRecentError)")
    }
    return nil
  }
  
  /**
  Return this Location's parent, or nil if this is a top-level location.
  */
  public func getParent() -> Location? {
    if parentPk == nil { return nil }
    do {
      let rows = try db().execute("SELECT * FROM locations WHERE pk = %@", parameters: parentPk)
      if let
        row = rows.first,
        location = Location(row: row)
      {
        return location
      }
    } catch {
      log("SQL error: \(db().mostRecentError)")
    }
    return nil
  }
  
  /**
  Return an Array of all parents, in reverse order.
  The first value in the array is the location's immediate parent; the second
  value is the parent's parent; and so on.
  */
  public func getParents() -> [Location] {
    // TODO: use a recursive SQL query instead of getting Swift to make lots of calls
    var parents: [Location] = []
    var thisLocation: Location? = self
    while thisLocation != nil {
      thisLocation = thisLocation?.getParent()
      if let loc = thisLocation {
        parents.append(loc)
      }
    }
    return parents
  }
  
  /**
  Return an array of child Locations in no particular order.
  */
//   public func getChildren() -> [Location] {
  public func getChildren() -> Set<Location> {
    do {
      let rows = try db().execute("SELECT * FROM locations WHERE parent_pk = %@", parameters: pk)
//       return rows.flatMap { Location(row: $0) }
      return Set(rows.flatMap { Location(row: $0) })
    } catch {
      log("SQL error: \(db().mostRecentError)")
    }
    return []
  }
  
  /**
  Add a location as a child of this location to the database.
  */
  public func insertChild(withName name: String) throws {
    try db().execute("INSERT INTO locations (parent_pk, name) VALUES (%@, %@)", parameters: pk, name)
  }
  
}

extension Location: Hashable {

  public var hashValue: Int {
    get {
      return pk
    }
  }
  
}

public func ==(lhs: Location, rhs: Location) -> Bool {
  return lhs.pk == rhs.pk
}
