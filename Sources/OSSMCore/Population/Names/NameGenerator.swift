import Random

/**
  Generates names for Sims.

  Set up: after the Geography is prepared, NameGenerator needs to be inited with
  a hash table of Locations along with available first and last names.

  Usage: call `generate(for:)` with a location. NameGenerator will return a Name
  value with a random name. If there are no names available for that location,
  then NameGenerator will throw `NameError.emptyNameList`.
*/

public class NameGenerator {

  let namesTable: [Location: NamesList]

  let randomGenerator: RandomProtocol

  public init(namesTable: [Location: NamesList], randomGenerator: RandomProtocol) {
    self.namesTable = namesTable
    self.randomGenerator = randomGenerator
  }

  public func generate(for location: Location) throws -> Name {
    // Choose a random name from the concatenated NamesLists of this location
    // and all parent locations.
    return try namesList(for: location).random(using: randomGenerator)
  }

  func namesList(for location: Location) -> NamesList {
    // Add together the NamesLists of this location and all its parent locations.
    return ([location] + location.allParents)
      .flatMap { namesTable[$0] }
      .reduce(NamesList(), +)
  }

}
