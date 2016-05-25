import Foundation
import PureJson
import ossmcore


private var _dbConfigured = false


func prepareTestDatabase() {
  // If db is not yet configured, configure it.
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
    do {
      guard let
        host = config["database"]?["host"]?.string,
        port = config["database"]?["port"]?.int,
        username = config["database"]?["username"]?.string,
        password = config["database"]?["password"]?.string,
        dbName = config["database"]?["dbName"]?.string
      else {
        log("Invalid database configuration.", level: .Error)
        exit(1)
      }
      try configureDatabase(host: host, port: port, username: username, password: password, databaseName: dbName)
      _dbConfigured = true
      print("Database connection succeeded.")
    } catch {
      log("Failed opening database", level: .Error)
      exit(1)
    }
  }
  // Now create tables
  // Ideally we'd be importing create.sql but that's causing me some trouble at the moment
  try! db().execute("DROP TABLE IF EXISTS users, locations, clubs CASCADE")
  // Users
  try! db().execute("CREATE TABLE users (password varchar(128) NOT NULL, last_login timestamp with time zone NULL, pk serial NOT NULL PRIMARY KEY, is_active boolean NOT NULL, email varchar(255) NOT NULL UNIQUE, nickname varchar(40) NOT NULL UNIQUE, timezone_name varchar(40) NOT NULL, language_code varchar(6) NOT NULL, token varchar(20) NOT NULL UNIQUE, face_recipe varchar(255) NOT NULL, access_level smallint NOT NULL CHECK (access_level >= 0));")
  try! db().execute("CREATE INDEX users_email ON users (email varchar_pattern_ops);")
  try! db().execute("CREATE INDEX users_nickname ON users (nickname varchar_pattern_ops);")
  try! db().execute("CREATE INDEX users_token ON users (token varchar_pattern_ops);")
  // Locations
  try! db().execute("CREATE TABLE locations (pk serial NOT NULL PRIMARY KEY, parent_pk INT REFERENCES locations(pk), name varchar(40) NOT NULL)")
  // Clubs
  try! db().execute("CREATE TABLE clubs (pk serial NOT NULL PRIMARY KEY, user_pk int NOT NULL REFERENCES users(pk), location_pk int NOT NULL REFERENCES locations(pk), name varchar(80) NOT NULL, badge_recipe varchar(255) NOT NULL, primary_colour varchar(6) NOT NULL, secondary_colour varchar(6) NOT NULL, tertiary_colour varchar(6) NOT NULL)")
}
