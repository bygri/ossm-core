import Node
import Foundation

public struct Color {

  public enum Error: Swift.Error {
    case invalidHexString(String)
  }

  public let hexString: String

  public init(_ hexString: String) throws {
    guard Color.isValidHexString(hexString) else {
      throw Error.invalidHexString(hexString)
    }
    self.hexString = hexString
  }

  static let hexInvalidCharset = CharacterSet(charactersIn: "1234567890ABCDEF").inverted
  static func isValidHexString(_ hex: String) -> Bool {
    // TODO: IMPROVE consider using a regex here: [0-9A-F]{6}
    guard hex.characters.count == 6 else {
      return false
    }
    return hex.uppercased().rangeOfCharacter(from: hexInvalidCharset) == nil
  }

}

extension Color: NodeConvertible {

  public init(node: Node) throws {
    hexString = try node.get()
    guard Color.isValidHexString(hexString) else {
      throw Error.invalidHexString(hexString)
    }
  }

  public func makeNode(in context: Context?) throws -> Node {
    return hexString.makeNode(in: context)
  }

}
