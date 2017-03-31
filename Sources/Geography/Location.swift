import Localization

/*
  A geographical location.

  Defined as a tree structure.
*/
public final class Location {

  public let name: TranslatableString
  public let parent: Location?

  public init(name: String, parent: Location?) {
    self.name = name
    self.parent = parent
  }

}


extension Location: Equatable {
  public static func == (lhs: Location, rhs: Location) -> Bool {
    return lhs === rhs
  }
}
