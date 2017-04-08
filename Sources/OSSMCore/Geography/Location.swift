/*
  A geographical location.

  Defined as a tree structure.

  The map of Locations is held in memory.
*/
public final class Location {

  public let name: TranslatableString
  public weak var parent: Location?
  public var children: [Location] = []

  public init(name: String, parent: Location?) {
    self.name = name
    if let parent = parent {
      parent.add(child: self)
    }
  }

  /*
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

  /*
    An array of all child Locations which do not themselves have children.
  */
  public var allTerminalChildren: [Location] {
    return children.reduce([]) {
      $1.isTerminal ?
        $0 + [$1] :
        $0 + $1.allTerminalChildren
    }
  }

  /*
    True if the Location has no child Locations.
  */
  public var isTerminal: Bool {
    return children.isEmpty
  }

  /// Add a child Location to this Location.
  func add(child: Location) {
    child.parent = self
    children.append(child)
  }

}


extension Location: Equatable {
  public static func == (lhs: Location, rhs: Location) -> Bool {
    return lhs === rhs
  }
}

// TODO: Remove or replace this once we have proper primary keys
extension Location: Hashable {
  public var hashValue: Int {
    return name.hashValue
  }
}
