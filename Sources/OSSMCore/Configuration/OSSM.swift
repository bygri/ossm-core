import Random
import Fluent

/*
  Service container for an OSSM instance. Brings together all related classes.

  Set your configurations on this class.
*/
public final class OSSM {

  /// The name of this instance.
  public let name: String

  /// Database for this instance.
  public let database: Database

  /// The instance's timeline.
  public let timeline = Timeline()

  /// The root location of this instance's geography.
  public let rootLocation: Location

  /// The name generator.
  public let nameGenerator: NameGenerator

  /// The random number generator to use.
  public let random: RandomProtocol

  public init(
    name: String,
    database: Database,
    rootLocation: Location,
    nameGenerator: NameGenerator,
    random: RandomProtocol?
  ) throws {
    self.name = name
    self.database = database
    self.rootLocation = rootLocation
    self.nameGenerator = nameGenerator
    self.random = try random ?? URandom()
  }

}
