import Vapor
import OSSMCore


func authenticatedUserPk(fromRequest request: Request) -> Int? {
  // Auth token may be in headers
  if let
    authorisationHeader = request.headers["authorization"].first,
    token = try? AuthToken(string: authorisationHeader)
  {
    log("Received auth token from header")
    return authenticatedUserPk(fromToken: token)
  }
  // Auth token may be in query string
  if let
    tokenString = request.data.query["token"]?.string,
    token = try? AuthToken(string: tokenString)
  {
    log("Received auth token from query string")
    return authenticatedUserPk(fromToken: token)
  }
  return nil
}
