import Random

extension NamesList {

  func random(using randomGenerator: RandomProtocol) throws -> Name {
    guard firstNames.count > 0, lastNames.count > 0 else {
      throw NameError.emptyNameList
    }
    return try Name(
      first: firstNames[abs(randomGenerator.makeInt() % firstNames.count)],
      last: lastNames[abs(randomGenerator.makeInt() % lastNames.count)]
    )
  }

}
