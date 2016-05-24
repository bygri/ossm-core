import Foundation
import SQL
import PostgreSQL

/**
CREATE TABLE "locations" (
  "l1" smallint,
  "l2" smallint,
  "l3" smallint,
  "l4" smallint,
  "name" varchar(40) NOT NULL
);
CREATE INDEX "locations_key" ON "locations" ("l1", "l2", "l3", "l4");
*/

public struct Location {

  let l1: Int
  let l2: Int?
  let l3: Int?
  let l4: Int?
  public let name: String

  public init(_ l1: Int, _ l2: Int?, _ l3: Int?, _ l4: Int?, name: String) {
    self.l1 = l1
    self.l2 = l2
    self.l3 = l3
    self.l4 = l4
    self.name = name
  }

  public static func keysAreValid(_ l1: Int, _ l2: Int?, _ l3: Int?, _ l4: Int?) -> Bool {
    if (l2 == nil && l3 == nil && l4 == nil) { return true }
    if (l2 != nil && l3 == nil && l4 == nil) { return true }
    if (l2 != nil && l3 != nil && l4 == nil) { return true }
    if (l2 != nil && l3 != nil && l4 != nil) { return true }
    return false
  }

}


extension Location {

  public init?(row: Row) {
    do {
      guard let
        l1: Int = try row.value("l1"),
        name: String = try row.value("name")
      else {
        return nil
      }
      self.init(l1, try? row.value("l2"), try? row.value("l3"), try? row.value("l4"), name: name)
    } catch let error {
      log("Init error: \(error)", level: .Error)
      return nil
    }
  }

  public static func get(_ l1: Int, _ l2: Int?, _ l3: Int?, _ l4: Int?) -> Location? {
    // Given level ids, get the row
    if !Location.keysAreValid(l1, l2, l3, l4) {
      return nil
    }
    // Because of a PostgreSQL connector 'bug'(?) I cannot seem to pass nil as a parameter so I have to make my own
    // queries based on the level of this Location.
    do {
      let result: PostgreSQL.Result = try {
        switch (l1, l2, l3, l4) {
        case (let l1, nil, nil, nil):
          return try db().execute("SELECT * FROM locations WHERE l1 = %@ and l2 IS NULL AND l3 IS NULL AND l4 IS NULL", parameters: l1)
        case (let l1, let l2, nil, nil):
          return try db().execute("SELECT * FROM locations WHERE l1 = %@ and l2 = %@ AND l3 IS NULL AND l4 IS NULL", parameters: l1, l2)
        case (let l1, let l2, let l3, nil):
          return try db().execute("SELECT * FROM locations WHERE l1 = %@ and l2 = %@ AND l3 = %@ AND l4 IS NULL", parameters: l1, l2, l3)
        case (let l1, let l2, let l3, let l4):
          return try db().execute("SELECT * FROM locations WHERE l1 = %@ and l2 = %@ AND l3 = %@ AND l4 = %@", parameters: l1, l2, l3, l4)
        }
      }()
      guard let row = result.first else {
        return nil
      }
      if let location = Location(row: row) {
        return location
      }
    } catch {
      log("SQL error: \(db().mostRecentError)", level: .Error)
    }
    return nil
  }

}
