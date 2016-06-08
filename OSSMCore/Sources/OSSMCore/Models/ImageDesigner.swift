/*
# ImageDesigner concept

The image designer is responsible for assisting a user to design and generate
an image from swappable, customisable components.

*/

protocol ImageComponentGroup {
  
}

protocol ImageComponent {
  var svgTemplate: String { get }
  func svgLayer() -> String
}
