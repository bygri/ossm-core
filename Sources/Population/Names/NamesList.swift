/**
  A list of first and last names, from which a Name can be generated randomly.

  Names are arrays, not sets, so names can be added multiple times to increase
  probability.

  NamesLists can be added together using the `+` operator.
*/
public struct NamesList {

  let firstNames: [String]
  let lastNames: [String]

  init(firstNames: [String] = [], lastNames: [String] = []) {
    self.firstNames = firstNames
    self.lastNames = lastNames
  }

}


extension NamesList {

  public static func + (left: NamesList, right: NamesList) -> NamesList {
    return NamesList(
      firstNames: left.firstNames + right.firstNames,
      lastNames: left.lastNames + right.lastNames
    )
  }

}
