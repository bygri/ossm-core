import Foundation
import PostgreSQL


public enum DatabaseOpenError: ErrorProtocol {
  case UnableToOpenDatabase
}


private var _db: Connection?


/**
  This must be run before the database is accessed at all.
*/
public func configureDatabase(host: String, port: Int, username: String, password: String, databaseName: String) throws {
  do {
    // db can only be opened through a C7.URI which is dumb
    let uri = URI(host: host, port: port, path: databaseName, userInfo: URI.UserInfo(username: username, password: password))
    let connectionInfo = try Connection.ConnectionInfo(uri)
    _db = Connection(connectionInfo)
    try _db!.open()
  } catch {
    throw DatabaseOpenError.UnableToOpenDatabase
  }
}


public func db() -> Connection {
  guard let db = _db else {
    log("Database accessed before being configured!")
    exit(1)
  }
  return db
}
