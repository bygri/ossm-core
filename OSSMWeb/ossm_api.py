from django.conf import settings
import requests


def get(url, *args, **kwargs):
  return requests.get(settings.API_URL + url, *args, **kwargs)

def post(url, *args, **kwargs):
  return requests.post(settings.API_URL + url, *args, **kwargs)
