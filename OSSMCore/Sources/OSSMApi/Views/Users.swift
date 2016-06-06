import Vapor
import OSSMCore
import Foundation

/*
  guard let authPk = authenticatedUserPk(fromRequest: request) else { return Response(status: .unauthorized) }
  if authPk != pk { return Response(status: .forbidden) }
*/

func userDetailView(_ request: Request, pk: Int) -> Response {
  do {
    guard let authPk = authenticatedUserPk(fromRequest: request) else { return Response(status: .unauthorized) }
    let user = try User.get(withPk: pk)
    if !user.isActive {
      return Response(status: .notFound)
    }
    if pk != authPk {
      return response(Json([
        "pk": user.pk,
        "isActive": user.isActive,
        "accessLevel": Int(user.accessLevel.rawValue),
        "nickname": user.nickname,
        "timezone": user.timezone,
        "language": user.language,
        "dateCreated": jsonFromDate(user.dateCreated),
        "lastLogin": jsonFromDate(user.lastLogin)
      ] as [String: JsonRepresentable]))
    } else {
      return response(Json([
        "pk": user.pk,
        "email": user.email,
        "authToken": user.authToken.stringValue,
        "verificationCode": jsonNullIfNot(user.verificationCode),
        "isActive": user.isActive,
        "accessLevel": Int(user.accessLevel.rawValue),
        "nickname": user.nickname,
        "timezone": user.timezone,
        "language": user.language,
        "dateCreated": jsonFromDate(user.dateCreated),
        "lastLogin": jsonFromDate(user.lastLogin)
      ] as [String: JsonRepresentable]))
    }
  } catch User.Error.DoesNotExist { return Response(status: .notFound)
  } catch let error { return responseServerError(error)
  }
}


func userAuthenticateView(_ request: Request) -> Response {
  do {
    guard let
      email = request.data["email"].string,
      password = request.data["password"].string
    else {
      throw OSSMApi.Error.ClientDataNotValid
    }
    guard let
      pk = try User.authenticateUser(withEmail: email, password: password)
    else {
      return Response(status: .unauthorized)
    }
    let user = try User.get(withPk: pk)
    return response(Json([
      "pk": pk,
      "authToken": user.authToken.stringValue
    ] as [String: JsonRepresentable]))
  } catch User.Error.DoesNotExist {
    return Response(status: .notFound)
  } catch let error {
    log("Unhandled error \(error)", level: .Error)
    return Response(status: .internalServerError, json: Json([
      "reason": "UNHANDLED_ERROR",
      "error": "\(error)"
    ]))
  }
}


func userCreateView(_ request: Request) -> Response {
  do {
    guard let
      email = request.data["email"].string,
      password = request.data["password"].string,
      timezone = request.data["timezone"].string,
      language = request.data["language"].string,
      nickname = request.data["nickname"].string
    else {
      throw OSSMApi.Error.ClientDataNotValid
    }
    let user = try User.create(
      withEmail: email,
      password: password,
      timezone: timezone,
      language: language,
      nickname: nickname)
    guard let verificationCode = user.verificationCode
    else { return Response(status: .internalServerError) }
    return response(Json([
      "pk": user.pk,
      "verificationCode": verificationCode
    ] as [String: JsonRepresentable]), status: .created)
  } catch User.Error.InvalidInput(let fields) {
    return Response(status: .badRequest, json: Json([
      "reason": "INVALID_INPUT",
      "fields": Json(fields.map({
        Json([$0.fieldName, $0.failureCode()])
      }) as [JsonRepresentable]),
    ] as [String: JsonRepresentable]))
  } catch User.Error.DuplicateKey(let key) {
    return Response(status: .badRequest, json: Json([
      "reason": "DUPLICATE_KEY",
      "field": key
    ]))
  } catch let error {
    log("Unhandled error \(error)", level: .Error)
    return Response(status: .internalServerError, json: Json([
      "reason": "UNHANDLED_ERROR",
      "error": "\(error)"
    ]))
  }
}


func userRegenerateTokenView(_ request: Request, pk: Int) -> Response {
  do {
    guard let
      password = request.data["password"].string
    else { return Response(status: .badRequest) }
    if try User.authenticateUser(withPk: pk, password: password) == nil {
      return Response(status: .unauthorized)
    }
    let user = try User.get(withPk: pk)
    let newToken = try user.regenerateToken()
    return response(Json([
      "authToken": newToken.stringValue
    ] as [String: JsonRepresentable]))
  } catch let error { return responseServerError(error)
  }

}


func userVerifyView(_ request: Request, pk: Int) -> Response {
  do {
    guard let
      code = request.data["code"].string
    else { return Response(status: .badRequest) }
    let user = try User.get(withPk: pk)
    if try user.verify(withCode: code) == false {
      return Response(status: .badRequest)
    }
    return Response(status: .noContent)
  } catch let error { return responseServerError(error)
  }
}
