import Vapor
import OSSMCore


func configureRoutes() {
  let app = server()
  app.get("") { request in
    return Json(["version": "0.0.1", "response": "Hello from ossm-api."])
  }

  //// USER routes

  /**
  Create a user (through a sign-up form).
  */
  app.post("user/create/", handler: userCreateView)

  /**
  Verify a user.
  */
  // app.get("user/verify/", Int.self, handler: userVerifyView)
  // app.post("user/verify/", Int.self, handler: userVerifyView)

  /**
    Return detail about a user.
  */
  app.get("user/", Int.self, handler: userDetailView)
}
