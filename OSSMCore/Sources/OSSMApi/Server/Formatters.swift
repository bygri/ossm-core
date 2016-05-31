import Foundation
import Vapor


private let _dateFormatter: NSDateFormatter = {
  let df = NSDateFormatter()
  df.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
  return df
}()


func dateFromString(_ string: String) -> NSDate? {
  return _dateFormatter.dateFromString(string)
}


func jsonFromDate(_ date: NSDate?) -> JsonRepresentable {
  if let date = date {
    return _dateFormatter.string(from: date)
  }
  return Json.null
}


// This is because putting ``"key": value ?? Json.null`` in code is currently failing.
func jsonNullIfNot(_ value: JsonRepresentable?) -> JsonRepresentable {
  if let value = value {
    return value
  }
  return Json.null
}
