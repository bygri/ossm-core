import Foundation
import PureJson
import ossmcore


private var _dbConfigured = false
private var _createQueryStrings: [String] = []


func prepareTestDatabase() {

  // Only once, configure the database connection by loading parameters from a test-config JSON file.
  if !_dbConfigured {
    // TODO: Don't hardcode this path. Once 'swift test' allows passing arguments to the test target,
    // this can be fixed.
    let configFilePath = "~/ossm-api.test-config.json".stringByExpandingTildeInPath
    if !NSFileManager.defaultManager().isReadableFile(atPath: configFilePath) {
      print("Configuration file does not exist or is not readable at path \(configFilePath).")
      exit(1)
    }
    guard let
      data = NSData(contentsOfFile: configFilePath),
      string = String(data: data, encoding: NSUTF8StringEncoding),
      config = try? Json.deserialize(string)
    else {
      print("Unable to decode configuration file at path \(configFilePath).")
      exit(1)
    }
    // Retrieve configuration from the config file
    guard let
      host = config["database"]?["host"]?.string,
      port = config["database"]?["port"]?.int,
      username = config["database"]?["username"]?.string,
      password = config["database"]?["password"]?.string,
      dbName = config["database"]?["dbName"]?.string,
      createFilePath = config["database"]?["createFilePath"]?.string?.stringByExpandingTildeInPath,
      secretKey = config["secretKey"]?.string
    else {
      log("Invalid database configuration.", level: .Error)
      exit(1)
    }
    // Now open a database connection and apply the configuration
    do {
      try configureDatabase(host: host, port: port, username: username, password: password, databaseName: dbName)
      _dbConfigured = true
      print("Database connection succeeded.")
    } catch {
      log("Failed opening database", level: .Error)
      exit(1)
    }
    // Fetch and store the table creation query strings
    if !NSFileManager.defaultManager().isReadableFile(atPath: createFilePath) {
      print("Create.sql file does not exist or is not readable at path \(createFilePath).")
      exit(1)
    }
    guard let
      createQueryData = NSData(contentsOfFile: createFilePath),
      createQueryString = String(data: createQueryData, encoding: NSUTF8StringEncoding)
    else {
      print("Unable to decode SQL file at path \(createFilePath).")
      exit(1)
    }
    _createQueryStrings = createQueryString.components(separatedBy: ";")
    // Set up the hasher
    configureHash(withKey: secretKey)
  }

  // Every time this is called, we want to re-create test tables.
  do {
    for queryString in _createQueryStrings {
      try db().execute(queryString)
    }
  } catch {
    log("SQL error when executing table creation queries: \(db().mostRecentError)", level: .Error)
  }
}
