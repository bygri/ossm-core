import Foundation
import PureJson
import OSSMCore


let VERSION = [0,0,1]
print("** ossm-api version \(VERSION[0]).\(VERSION[1]).\(VERSION[2]) **")

// Parse command-line input and fetch configuration JSON
let args = NSProcessInfo.processInfo().arguments
if args.count != 2 {
  print("Usage: ossm-api [path-to-config.json]")
  exit(1)
}
if !NSFileManager.defaultManager().isReadableFile(atPath: args[1]) {
  print("Configuration file does not exist or is not readable at path \(args[1]).")
  exit(1)
}
guard let
  data = NSData(contentsOfFile: args[1]),
  string = String(data: data, encoding: NSUTF8StringEncoding),
  config = try? Json.deserialize(string)
else {
  print("Unable to decode configuration file at path \(args[1]).")
  exit(1)
}


// Configure logging
if let
  logLevelInt = config["loglevel"]?.int,
  logLevel = LogLevel(rawValue: logLevelInt)
{
  setLogLevel(logLevel)
  print("Log level \(getLogLevel())")
} else {
  log("Invalid log level. Use key 'loglevel'.", level: .Error)
  exit(1)
}


// Configure database
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
  log("Database connection succeeded.")
} catch {
  log("Failed opening database", level: .Error)
  exit(1)
}


// Configure hash
if let secretKey = config["secretKey"]?.string {
  configureHash(withKey: secretKey)
} else {
  log("No secret key!", level: .Error)
  exit(1)
}


// Verify game environment.
if Location.getRoot() == nil {
  log("There is no root Location found in the database.", level: .Error)
  exit(1)
}


// Configure and start server
do {
  if let
    host = config["server"]?["host"]?.string,
    port = config["server"]?["port"]?.int
  {
    try configureServer(host: host, port: port)
    configureRoutes()
    try startServer()
  } else {
    log("Invalid port specification", level: .Error)
    exit(1)
  }
} catch {
  log("Failed configuring server", level: .Error)
}
