/**
  We need to be able to authorise certain requests.
  The client does this by sending us an auth token with each
  request. We check that against our list of users to see
  what information they are authorised to access.
  Because this happens at least once per request, we cache
  User pks and tokens.
  If we want to deny a client access by changing their token in
  the database, we'll need to purge this cache as well.
*/
import Foundation
import OSSMCore


private let cache = NSCache()


public enum AuthError: ErrorProtocol {
  case UserDoesNotExist
  case InvalidToken
}


public func authenticatedUserPk(fromToken token: User.AuthToken) -> Int? {
  // In the cache, the token is the key, and the userPk is the value
  // If the pk and token are already cached, and match, then return happily.
  if let pk = (cache.object(forKey: NSString(string: token.stringValue)) as? NSNumber)?.integerValue {
    log("Retrieved user \(pk) from cache.", level: .Debug)
    return pk
  }
  // Failing this, load the data from the database.
  log("Not cached, fetching from database.", level: .Debug)
  do {
    if let pk = try User.getPk(forAuthToken: token) {
      // Store the token and pk in our cache
      log("Caching fetched token for user \(pk)")
      cache.setObject(NSNumber(integer: pk), forKey: NSString(string: token.stringValue), cost: 40)
      return pk
    }
  } catch {}
  log("Invalid authentication token.", level: .Warn)
  return nil
}


public func purgeCachedToken(token: User.AuthToken) {
  cache.removeObject(forKey: NSString(string: token.stringValue))
}


public func purgeAllCachedTokens() {
  cache.removeAllObjects()
}
