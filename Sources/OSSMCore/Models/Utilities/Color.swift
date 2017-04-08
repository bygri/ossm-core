import Node

public struct Color {

  public enum Error: Swift.Error {
    case invalidHexString(String)
  }

  public let hexString: String

  public init(_ hexString: String) throws {
    self.hexString = hexString
  }

  public init(red: String, blue: String, green: String) throws {
    hexString = red + blue + green
  }

}

extension Color: NodeConvertible {

  public init(node: Node) throws {
    hexString = try node.get()
  }

  public func makeNode(in context: Context?) throws -> Node {
    return hexString.makeNode(in: context)
  }

}
