import Vapor


public enum ServerRunError: ErrorProtocol {
  case NotConfigured
}


private var _server: Application?
private var _host: String?
private var _port: Int?


public func configureServer(host: String, port: Int) throws {
  _server = Application()
  _host = host
  _port = port
}


public func server() -> Application {
  return _server!
}


public func startServer() throws {
  guard let server = _server, host = _host, port = _port else {
    throw ServerRunError.NotConfigured
  }
  server.start(ip: host, port: port)
}
