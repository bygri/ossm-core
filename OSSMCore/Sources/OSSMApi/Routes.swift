import Vapor
import OSSMCore


func configureRoutes() {

  let app = server()
  app.get("") { request in
    return Json([
      "version": Json(VERSION.map({ $0 as JsonRepresentable })),
      "response": "Hello from ossm-api."
    ])
  }

  //// USER routes

  app.get ("user/", Int.self, handler: userDetailView)
  app.post("user/authenticate", handler: userAuthenticateView)
  app.post("user/create", handler: userCreateView)
  app.post("user/regenerateToken", Int.self, handler: userRegenerateTokenView)
  app.post("user/verify", Int.self, handler: userVerifyView)

}
