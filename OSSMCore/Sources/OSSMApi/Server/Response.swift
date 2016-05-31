import OSSMCore
import Vapor
import S4


func response(_ obj: Json, status: Status = Status.ok) -> Response {
  return Response(status: status, json: Json([
    "version": Json(VERSION.map({ $0 as JsonRepresentable })),
    "data": obj
  ] as [String: JsonRepresentable]))
}


func responseServerError(_ error: ErrorProtocol) -> Response {
  log("Unhandled error: \(error)", level: .Error)
  return Response(status: .internalServerError, text: "Unhandled error")
}
