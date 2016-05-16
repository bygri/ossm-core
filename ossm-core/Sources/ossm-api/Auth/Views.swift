import Vapor
import ossmcore


func authenticatedUserPk(fromRequest request: Request) -> Int? {
  // Auth token may be in headers
  if let
    authorisationHeader = request.headers["authorization"].first,
    token = User.AuthToken(string: authorisationHeader)
  {
    log("Received auth token from header")
    return authenticatedUserPk(fromToken: token)
  }
  // Auth token may be in query string
  if let
    tokenString = request.data.query["token"]?.string,
    token = User.AuthToken(string: tokenString)
  {
    log("Received auth token from query string")
    return authenticatedUserPk(fromToken: token)
  }
  return nil
}
