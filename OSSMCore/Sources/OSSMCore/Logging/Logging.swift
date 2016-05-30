public enum LogLevel: Int {
  case Debug = 3
  case Warn = 2
  case Error = 1
  case None = 0
}


private var _logLevel = LogLevel.Error


public func log(_ message: String, level: LogLevel = .Debug) {
  if level.rawValue <= _logLevel.rawValue {
    switch level {
      case .Debug: print("DEBUG: "+message)
      case .Warn:  print("WARN:  "+message)
      case .Error: print("ERROR: "+message)
      case .None:  break
    }
  }
}


public func setLogLevel(_ level: LogLevel) {
  _logLevel = level
}


public func getLogLevel() -> LogLevel {
  return _logLevel
}
