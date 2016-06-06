import Vapor
import OSSMCore


func authenticatedUserPk(fromRequest request: Request) -> Int? {
  // Auth token is retrieved from header
  if let
    authorisationHeader = request.headers["authorization"].first,
    token = try? AuthToken(string: authorisationHeader)
  {
    return authenticatedUserPk(fromToken: token)
  }
  return nil
}
