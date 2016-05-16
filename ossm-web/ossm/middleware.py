import pytz
from django.utils import timezone, translation


class TimezoneMiddleware(object):
  '''This must happen AFTER auth.'''
  def process_request(self, request):
    # Fetch timezone from user preferences
    if request.user and request.user.is_authenticated():
      timezone.activate(pytz.timezone(request.user.timezone_name))
    else:
      timezone.deactivate()

class LocaleMiddleware(object):
  def process_request(self, request):
    # Fetch language from user preferences
    if request.user and request.user.is_authenticated():
      language_code = request.user.language_code
    else:
      language_code = translation.get_language_from_request(request)
    request.LANGUAGE_CODE = language_code
    translation.activate(language_code)

  def process_response(self, request, response):
    if 'Content-Language' not in response:
      response['Content-Language'] = translation.get_language()
    return response
