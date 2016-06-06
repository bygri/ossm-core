'''
These settings are common to all installations.

For installation-specific settings, create a file local_settings.py, using the following example as a template:

from .settings import *
DEBUG = True
ALLOWED_HOSTS = ['domain.com',]
SECRET_KEY = 'SET_ME'
STATIC_ROOT = os.path.join(BASE_DIR, 'www')
SESSION_ENGINE = 'django.contrib.sessions.backends.signed_cookies' # or set up DATABASES

# ossm-api
API_URL = 'http://localhost:8001'

# Slack inviter
SLACK_TEAM = 'ossm'
SLACK_TOKEN = '12345'
SLACK_DEFAULT_CHANNELS = []
'''
import os


API_VERSION = [0,0,1]


# URLs and paths

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WSGI_APPLICATION = 'ossm.wsgi.application'
ROOT_URLCONF = 'ossm.urls'
STATIC_URL = '/assets/'


# Installed apps

INSTALLED_APPS = [
  'django.contrib.sessions',
  'django.contrib.staticfiles',
  'ossm_user',
  'ossm_site',
  'ossm_community',
]

MIDDLEWARE_CLASSES = [
  'django.middleware.security.SecurityMiddleware',
  'django.contrib.sessions.middleware.SessionMiddleware',
  'django.middleware.common.CommonMiddleware',
  'django.middleware.csrf.CsrfViewMiddleware',
  'django.middleware.clickjacking.XFrameOptionsMiddleware',
]


# Template system

TEMPLATES = [
  {
    'BACKEND': 'django.template.backends.django.DjangoTemplates',
    'DIRS': [os.path.join(BASE_DIR, 'templates')],
    'APP_DIRS': True,
    'OPTIONS': {
      'context_processors': [
        'django.template.context_processors.debug',
        'django.template.context_processors.request',
        'ossm_user.context_processors.auth',
      ],
    },
  },
]


# Internationalisation

LANGUAGE_CODE = 'en-AU'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_L10N = True
USE_TZ = True
LANGUAGES = [
  ('en-AU', 'Australian'),
  ('en-PIRAT', 'Pirate'),
  ('sv-CHEF', 'Swedish Chef'),
]
LOCALE_PATHS = [
  os.path.join(BASE_DIR, 'locale'),
]


# Static files

STATICFILES_DIRS = ( os.path.join(BASE_DIR, 'static'), )
