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

  public enum Error: ErrorProtocol {
    case RootAlreadyExists
  }
  
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
  public func getChildren() -> Set<Location> {
    do {
      let rows = try db().execute("SELECT * FROM locations WHERE parent_pk = %@", parameters: pk)
      return Set(rows.flatMap { Location(row: $0) })
    } catch {
      log("SQL error: \(db().mostRecentError)")
    }
    return Set()
  }
  
  /**
  Add a root location to the database.
  */
  public static func addRoot(withName name: String) throws -> Location? {
    if Location.getRoot() != nil { throw Error.RootAlreadyExists }
    let result = try db().execute("INSERT INTO locations (parent_pk, name) VALUES (NULL, %@) RETURNING *", parameters: name)
    if let row = result.first {
      return Location(row: row)
    }
    return nil
  }
  
  /**
  Add a location as a child of this location to the database.
  */
  public func insertChild(withName name: String) throws -> Location? {
    let result = try db().execute("INSERT INTO locations (parent_pk, name) VALUES (%@, %@) RETURNING *", parameters: pk, name)
    if let row = result.first {
      return Location(row: row)
    }
    return nil
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
