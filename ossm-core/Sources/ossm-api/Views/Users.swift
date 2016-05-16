import Vapor
import ossmcore


func userListView(_ request: Request) -> Response {
  let users = User.all().filter { $0.isActive == true }
  return response(Json(
    [
      "users": Json(
        users.map({
          Json([
            "pk": $0.pk,
            "nickname": $0.nickname,
            "timezoneName": $0.timezoneName,
            "language": $0.language.rawValue,
            "accessLevel": Int($0.accessLevel.rawValue),
          ])
        }) as [JsonRepresentable]
      )
    ] as [String: JsonRepresentable]
  ))
}


func userDetailView(request: Request, userPk: Int) -> Response {
  guard let myPk = authenticatedUserPk(fromRequest: request) else {
    return responseFail(reason: "Not authenticated")
  }
  guard let user = User.get(withPk: userPk) else {
    return responseFail(reason: "User not found")
  }
  // If this is a different user, show summary info
  if myPk != userPk {
    return response(Json([
      "userIsMe": false,
      "user": Json([
        "pk": user.pk,
        "nickname": user.nickname,
        "timezoneName": user.timezoneName,
      ] as [String: JsonRepresentable])
    ] as [String: JsonRepresentable]))
  }
  // If this is my user object, show detailed info
  return response(Json([
    "userIsMe": true,
    "user": Json([
      "pk": user.pk,
      "nickname": user.nickname,
      "timezoneName": user.timezoneName,
    ] as [String: JsonRepresentable])
  ] as [String: JsonRepresentable]))
}
