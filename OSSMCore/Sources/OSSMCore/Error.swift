/**
User input to a model was not valid.

``fieldName`` generally refers to the name of the model field which failed
validation.
*/
public struct ValidationError: ErrorProtocol {
  public enum Failure {
    case Length
    case Characters
    case Email
  }
  public let fieldName: String
  public let failure: Failure
}

/**
Top-level errors.
*/
public enum Error: ErrorProtocol {

  /**
  An error not handled elsewhere.
  */
  case UnhandledError(debugMessage: String, extra: Any?)

  /**
  The system has encountered unexpected invalid data from a trusted source,
  for example invalid data retrieved from the database.
  */
  case IntegrityError(debugMessage: String, extra: Any?)

}
