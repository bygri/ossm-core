import Vapor
import Foundation


private var _hash: Hash? = nil


public func configureHash(withKey key: String) {
  _hash = Hash()
  _hash!.key = key
}

public func hashedString(_ string: String) -> String {
  guard let hash = _hash else {
    log("Hash accessed before being configured!", level: .Error)
    exit(1)
  }
  return hash.make(string)
}
