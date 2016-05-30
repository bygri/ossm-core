from django.conf import settings
import requests


def fetch(path, user=None):
  headers = {}
  if user.is_authenticated:
    headers['Authorization'] = user.token
  r = requests.get(settings.API_URL+'/'+path, headers=headers)
  j = r.json()
  if j['version'] != settings.API_VERSION:
    raise Exception('API version mismatch.')
  return j['context']
