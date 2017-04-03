/*
  Simple struct to store a Sim's name.
*/
public struct Name {

  public let first: String
  public let last: String
  public let nickname: String?

  public init(first: String, last: String, nickname: String? = nil) {
    self.first = first
    self.last = last
    self.nickname = nickname
  }

}
