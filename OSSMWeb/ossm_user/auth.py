from functools import wraps
import ossm_api
from django.http import HttpResponseRedirect
from django.core.urlresolvers import reverse


def login_required(func):
  @wraps(func)
  def _decorated(request, *args, **kwargs):
    user = Auth(request)
    if not user.is_authenticated:
      return HttpResponseRedirect(reverse('user_login'))
    return func(request, *args, **kwargs)
  return _decorated


def anonymous_required(func):
  @wraps(func)
  def _decorated(request, *args, **kwargs):
    user = Auth(request)
    if user.is_authenticated:
      return HttpResponseRedirect(reverse('user_detail_self'))
    return func(request, *args, **kwargs)
  return _decorated


class Auth:
  '''
  A simple way to interact with session-based authentication.
  Instantiating this class gives easy access to details of the currently-logged in user.
  '''
  def __init__(self, request):
    session = request.session
    if 'user_pk' in session:
      self.is_authenticated = True
      self.user_pk = session['user_pk']
      self.token = session['auth_token']
      self.nickname = session['nickname']
      self.timezone = session['timezone']
      self.language = session['language']
    else:
      self.is_authenticated = False

  @staticmethod
  def login(request, pk, token):
    '''
    Set the current user as identified by ``pk`` and ``token``.
    '''
    session = request.session
    session.clear()
    session.cycle_key()
    session['user_pk'] = pk
    session['auth_token'] = token

  @staticmethod
  def logout(request):
    request.session.flush()

  @staticmethod
  def refresh(request):
    session = request.session
    if not 'user_pk' in session:
      return
    pk = session['user_pk']
    r = ossm_api.get('/user/{}'.format(pk), headers={'Authorization': session['auth_token']})
    j = r.json()['data']
    session['nickname'] = j['nickname']
    session['timezone'] = j['timezone']
    session['language'] = j['language']

  def fetch_data(self, request):
    session = request.session
    if not 'user_pk' in session:
      return
    pk = session['user_pk']
    r = ossm_api.get('/user/{}'.format(pk), headers={'Authorization': session['auth_token']})
    j = r.json()['data']
    return j
