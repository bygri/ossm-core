from .auth import Auth


def auth(request):
  return {'auth': Auth(request)}
