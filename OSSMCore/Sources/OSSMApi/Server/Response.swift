import Vapor


func response(_ obj: Json) -> Response {
  return Response(status: .ok, json: Json([
    "version": Json(VERSION.map({ $0 as JsonRepresentable })),
    "context": obj
  ] as [String: JsonRepresentable]))
}


func responseFail(reason: String) -> Response {
  return Response(status: .internalServerError, text: reason)
}
