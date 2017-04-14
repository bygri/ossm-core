import Fluent

public enum NodeConvertibleEnumError: Swift.Error {
  case invalidEnumValue(enum: Any.Type, value: Any)
}

protocol NodeConvertibleEnum: NodeConvertible {

  associatedtype RawValueType: NodeConvertible

  var rawValue: RawValueType { get }

  init?(rawValue: RawValueType)
  init(node: Node) throws

  func makeNode(in context: Context?) throws -> Node

}

extension NodeConvertibleEnum {

  public init(node: Node) throws {
    let raw: RawValueType = try node.get()
    guard let c = Self(rawValue: raw) else {
      throw NodeConvertibleEnumError.invalidEnumValue(enum: Self.self, value: raw)
    }
    self = c
  }

  public func makeNode(in context: Context?) throws -> Node {
    return try rawValue.makeNode(in: context)
  }

}
