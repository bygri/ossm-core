import OSSMCore


extension ValidationError {
  func failureCode() -> String {
    switch failure {
      case .Length: return "LENGTH"
      case .Characters: return "CHARACTERS"
      case .Email: return "EMAIL"
    }
  }
}


/**
API-specific top-level errors.
*/
enum Error: ErrorProtocol {

  /**
  The data supplied by the client was not valid.
  */
  case ClientDataNotValid

}
