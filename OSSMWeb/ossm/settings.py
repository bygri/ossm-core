'''
These settings are common to all installations.

For installation-specific settings, create a file local_settings.py, using the following example as a template:

from .settings import *
DEBUG = True
ALLOWED_HOSTS = ['domain.com',]
SECRET_KEY = 'SET_ME'
DATABASES = {
  'default': {
    'ENGINE': 'django.db.backends.postgresql',
    'HOST': 'localhost',
    'NAME': 'ossm',
    'USER': 'ossm',
    'PASSWORD': 'password'
  }
}
STATIC_ROOT = os.path.join(BASE_DIR, 'www')

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
LOGIN_URL = '/user/login/'
LOGIN_REDIRECT_URL = '/user/'
LOGOUT_URL = '/user/logout/'


# Installed apps

INSTALLED_APPS = [
  'django.contrib.auth',
  'ossm_auth',
  'django.contrib.admin',
  'django.contrib.contenttypes',
  'django.contrib.sessions',
  'django.contrib.messages',
  'django.contrib.staticfiles',
  'ossm_web',
  'slackinviter',
]

MIDDLEWARE_CLASSES = [
  'django.middleware.security.SecurityMiddleware',
  'django.contrib.sessions.middleware.SessionMiddleware',
  # 'django.middleware.locale.LocaleMiddleware',
  'django.middleware.common.CommonMiddleware',
  'django.middleware.csrf.CsrfViewMiddleware',
  'django.contrib.auth.middleware.AuthenticationMiddleware',
  'django.contrib.auth.middleware.SessionAuthenticationMiddleware',
  'ossm.middleware.LocaleMiddleware',
  'ossm.middleware.TimezoneMiddleware',
  'django.contrib.messages.middleware.MessageMiddleware',
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
        'django.contrib.auth.context_processors.auth',
        'django.contrib.messages.context_processors.messages',
      ],
    },
  },
]


# Authentication

AUTH_USER_MODEL = 'ossm_auth.User'

AUTH_PASSWORD_VALIDATORS = [
  {
    'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
  },
  {
    'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
  },
]


# Internationalisation

LANGUAGE_CODE = 'en-au'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_L10N = True
USE_TZ = True
LANGUAGES = [
  ('en-au', 'Australian'),
  ('pirate', 'Pirate'),
]
LOCALE_PATHS = [
  os.path.join(BASE_DIR, 'locale'),
]


# Static files

STATICFILES_DIRS = ( os.path.join(BASE_DIR, 'static'), )
