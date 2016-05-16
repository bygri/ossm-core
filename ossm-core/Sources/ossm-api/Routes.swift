import Vapor
import ossmcore


func configureRoutes() {
  let app = server()
  app.get("") { request in
    return Json(["version": "0.0.1", "response": "Hello from ossm-api."])
  }

  /**
    Return a list of all users.
  */
  app.get("user/list/", handler: userListView)

  /**
    Return detail about a single user.
  */
  app.get("user/", Int.self, handler: userDetailView)
}
