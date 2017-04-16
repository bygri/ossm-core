import Fluent

extension Date: NodeConvertible {

  public init(node: Node) throws {
    self.init(seconds: try node.get())
  }

  public func makeNode(in context: Context?) throws -> Node {
    return Node(toSeconds())
  }

}
