// Start simple
// Three head shapes, three Colors
// Two eye shapes, three Colors
// that'll do for now

// Definitions
struct LayerLibrary {
  let index: Int
  let name: String
  let components: [ComponentDefinition]
  var numberOfComponents: Int {
    return components.count
  }
}

struct ComponentDefinition {
  let index: Int
  let hasPrimaryColor: Bool
  let hasSecondaryColor: Bool
  let svgTemplate: String
  let colorPalette: [String]?
  func svgLayer(primaryColor: String?, secondaryColor: String?) -> String {
    return svgTemplate
  }
}

// Instances
struct Face {

  enum Error: ErrorProtocol {
    case InvalidRecipe
  }

  let layers: [Layer]
  
  /*
  init(fromRecipe recipe: String) throws {
    layers = try recipe.components(separatedBy: ".").map {
      // parse contents here is better
      var layerRecipe = $0.characters
      var primaryColor: String?
      var secondaryColor: String?
      if let primaryIndex = layerRecipe.index(where: { $0 == "-" }) {
        primaryColor = "\(primaryIndex)"
      }
      if let secondaryIndex = layerRecipe.index(where: { $0 == ":" }) {
        secondaryColor = "\(secondaryIndex)"
      }
      return Layer(index: 0, componentIndex: Int($0)!, primaryColor: primaryColor, secondaryColor: secondaryColor)
    }
  }
  
  func recipe() -> String {
    // Recipe be like "1-FF0000.3-00FF00:0000FF.2.5.2.3"
    return layers.map({
      var out = String($0.componentPk)
      if let color = $0.primaryColor {
        out += "-\(color)"
      }
      if let color = $0.secondaryColor {
        out += "#\(color)"
      }
      return out
    }).joined(separator: ".")
  }
  */
  
}

struct Layer {
  let index: Int
  let componentIndex: Int
  let primaryColor: String?
  let secondaryColor: String?
}
  

struct FaceDesigner {

  private static let skinTonePalette = [
    "FF0000", "FFFF00", "00FFFF",
  ]
  private static let eyeColorPalette = [
    "660000", "006600", "000066"
  ]
  
  static let library: [LayerLibrary] = [
    LayerLibrary(index: 0, name: "head", components: [
      ComponentDefinition(index: 0, hasPrimaryColor: true, hasSecondaryColor: false, svgTemplate: "headOne", colorPalette: skinTonePalette),
      ComponentDefinition(index: 1, hasPrimaryColor: true, hasSecondaryColor: false, svgTemplate: "headTwo", colorPalette: skinTonePalette),
      ComponentDefinition(index: 2, hasPrimaryColor: true, hasSecondaryColor: false, svgTemplate: "headThree", colorPalette: skinTonePalette),
    ]),
    LayerLibrary(index: 0, name: "eyes", components: [
      ComponentDefinition(index: 0, hasPrimaryColor: true, hasSecondaryColor: false, svgTemplate: "eyeOne", colorPalette: eyeColorPalette),
      ComponentDefinition(index: 1, hasPrimaryColor: true, hasSecondaryColor: false, svgTemplate: "eyeTwo", colorPalette: eyeColorPalette),
    ])
  ]
  
}


let myFace = Face(layers: [
  Layer(index: 0, componentIndex: 1, primaryColor: "FF0000", secondaryColor: nil),
  Layer(index: 1, componentIndex: 0, primaryColor: "00FFFF", secondaryColor: "FF00FF"),
])


/*

let faceDefinitions = [
  Group(name: "Head", components: [
    Component("round", hasPrimaryColor: true, hasSecondaryColor: false),
    Component("square"),
  ]),
  Group(name: "Eyes", components: [
    Component("round"),
    Component("sleepy"),
  ])

]

let face = [
  "Head": ComponentInstance("round", primaryColor: NSColor.redColor()),
  "Eyes": ComponentInstance("sleepy"),
]
let faceRecipe = """
{
  "head": {
    "id": 1, "primaryColor": "FF0000",
  },
  "eyes": {
    "id": 0, "primaryColor": "333333",
  },
}
"""
face.generateSVG()



*/
