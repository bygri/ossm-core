/**
  A geographical location.

  Defined as a tree structure.

  After building up your locations tree, call `Location.buildIndex(fromRoot:)`
  with the root location to build the lookup index. This will allow you to use
  `Location.fetch(at:)` to get locations by id number, along with standard
  traversal properties such as `parent` and `children`.
*/
public final class Location {

  public enum Error: Swift.Error {
    case duplicateLocationId(Int)
    case noIndex
  }

  static var index: [Int: Location]? = nil

  public let id: Int
  public let name: TranslatableString
  public weak var parent: Location?
  public let children: [Location]

  public init(id: Int, name: TranslatableString, children: [Location] = []) throws {
    self.id = id
    self.name = name
    self.children = children
    children.forEach { $0.parent = self }
  }

  /**
    Return the Location with the given ID number, or `nil` if there is no
    Location by that ID.

    May throw `Location.Error.noIndex` if `Location.buildIndex(fromRoot:)` has
    not yet been called.
  */
  static func find(_ id: Int) throws -> Location? {
    guard let index = index else {
      throw Error.noIndex
    }
    guard let loc = index[id] else {
      return nil
    }
    return loc
  }

  /**
    Build up the internal index of IDs to Locations. Call this after all
    Locations have been instantiated. The root Location must be passed in.

    May throw `Location.Error.duplicateLocationId` if a location ID has been
    used more than once in the Location tree.
  */
  static func buildIndex(fromRoot root: Location) throws {
    index = try ([root] + root.allChildren).reduce([:]) { acc, loc in
      var index = acc
      guard index[loc.id] == nil else {
        throw Error.duplicateLocationId(loc.id)
      }
      index[loc.id] = loc
      return index
    } as [Int: Location]
  }

  /**
    An array of the parents of this Location, all the way back to the root.

    The first element is this Location's immediate parent, the second is the
    first element's parent, and so on.

    Example response:

      sydney.allParents // ["NSW", "Australia", "Oceania", "World"]
  */
  public var allParents: [Location] {
    guard let parent = parent else { return [] }
    return [parent] + parent.allParents
  }

  /**
    An array of all child Locations in no particular order.
  */
  public var allChildren: [Location] {
    return children.reduce([]) {
      $1.isTerminal ?
        $0 + [$1] :
        $0 + [$1] + $1.allChildren
    }
  }

  /**
    An array of all child Locations which do not themselves have children.
  */
  public var allTerminalChildren: [Location] {
    return children.reduce([]) {
      $1.isTerminal ?
        $0 + [$1] :
        $0 + $1.allTerminalChildren
    }
  }

  /**
    True if the Location has no child Locations.
  */
  public var isTerminal: Bool {
    return children.isEmpty
  }

}


extension Location: Equatable {
  public static func == (lhs: Location, rhs: Location) -> Bool {
    return lhs === rhs
  }
}


extension Location: Hashable {
  public var hashValue: Int {
    return id
  }
}
