import Foundation
import PostgreSQL
import SQL

/*
CREATE TABLE clubs (
  pk serial NOT NULL PRIMARY KEY,
  owner_user_pk int NOT NULL REFERENCES users(pk),
  location_pk int NOT NULL REFERENCES locations(pk),
  name varchar(80) NOT NULL,
  badge_recipe varchar(255) NOT NULL,
  primary_colour varchar(6) NOT NULL,
  secondary_colour varchar(6) NOT NULL,
  tertiary_colour varchar(6) NOT NULL
);
*/

public struct Club {

  public enum Kind: String {
    /// Owned by a single user; a normal club.
    case Private = "priv"
    /// A 'national team', or equivalent. One person is granted ownership and they may draw their players from all
    /// players born in that location (or sub-locations).
    case Representative = "repr"
  }

  public let pk: Int
  let kind: Kind
  let ownerUserPk: Int
  let locationPk: Int
  public let name: String
  let badgeRecipe: String
  let primaryColour: String
  let secondaryColour: String
  let tertiaryColour: String

  public init(pk: Int, kind: Kind, ownerUserPk: Int, locationPk: Int, name: String, badgeRecipe: String, primaryColour: String, secondaryColour: String, tertiaryColour: String) {
    self.pk = pk
    self.kind = kind
    self.ownerUserPk = ownerUserPk
    self.locationPk = locationPk
    self.name = name
    self.badgeRecipe = badgeRecipe
    self.primaryColour = primaryColour
    self.secondaryColour = secondaryColour
    self.tertiaryColour = tertiaryColour
  }

}


extension Club {

  public init?(row: Row) {
    do {
      guard let
        pk: Int = try row.value("pk"),
        kindString: String = try row.value("kind_code"), kind = Kind(rawValue: kindString),
        ownerUserPk: Int = try row.value("owner_user_pk"),
        locationPk: Int = try row.value("location_pk"),
        name: String = try row.value("name"),
        badgeRecipe: String = try row.value("badge_recipe"),
        primaryColour: String = try row.value("primary_colour"),
        secondaryColour: String = try row.value("secondary_colour"),
        tertiaryColour: String = try row.value("tertiary_colour")
      else {
        return nil
      }
      self.init(pk: pk, kind: kind, ownerUserPk: ownerUserPk, locationPk: locationPk, name: name, badgeRecipe: badgeRecipe, primaryColour: primaryColour, secondaryColour: secondaryColour, tertiaryColour: tertiaryColour)
    } catch let error {
      log("Init error: \(error)", level: .Error)
      return nil
    }
  }

  public static func get(withPk pk: Int) -> Club? {
    do {
      if let row = try db().execute("SELECT * FROM clubs WHERE pk = %@", parameters: pk).first {
        return Club(row: row)
      }
    } catch {
      log("SQL error: \(db().mostRecentError)")
    }
    return nil
  }

  public static func get(forUser user: User) -> Club? {
    do {
      if let row = try db().execute("SELECT * FROM clubs WHERE user_pk = %@", parameters: user.pk).first {
        return Club(row: row)
      }
    } catch {
      log("SQL error: \(db().mostRecentError)")
    }
    return nil
  }

  public static func create(ofKind kind: Kind, forOwner user: User, inLocation location: Location, withName name: String, badgeRecipe: String, primaryColour: String, secondaryColour: String, tertiaryColour: String) throws -> Club? {
    // TODO: Validate colour. I think we need a utility Colour struct much like User.AuthToken, but separate to Club, which validates itself.
    let result = try db().execute("INSERT INTO clubs (kind_code, owner_user_pk, location_pk, name, badge_recipe, primary_colour, secondary_colour, tertiary_colour) VALUES (%@, %@, %@, %@, %@, %@, %@, %@) RETURNING *",
      parameters: kind.rawValue, user.pk, location.pk, name, badgeRecipe, primaryColour, secondaryColour, tertiaryColour)
      if let row = result.first {
        return Club(row: row)
      }
      return nil
  }

}
