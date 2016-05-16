from enum import Enum
from django.conf import settings
from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager
import pytz


class UserManager(BaseUserManager):
  def create_user(self, email, nickname, timezone_name, language_code, password=None):
    token = self.make_random_password(length=40)
    user = User.objects.create(
      email=email, nickname=nickname, timezone_name=timezone_name, language_code=language_code, token=token
    )
    user.set_password(password)
    user.save()

  def create_superuser(self, email, nickname, timezone_name, language_code, password):
    token = self.make_random_password(length=40)
    user = User.objects.create(
      email=email, nickname=nickname, timezone_name=timezone_name, language_code=language_code, token=token,
      access_level=User.AccessLevel.Superuser.value
    )
    user.set_password(password)
    user.save()


class User(AbstractBaseUser):
  class AccessLevel(Enum):
    User = 1
    Moderator = 20
    Administrator = 30
    Superuser = 99

  id = models.AutoField(primary_key=True, db_column='pk')
  is_active = models.BooleanField(default=True)
  email = models.EmailField(max_length=255, unique=True)
  nickname = models.CharField(max_length=40, unique=True)
  timezone_name = models.CharField(max_length=40, choices=[(t, t) for t in pytz.common_timezones])
  language_code = models.CharField(max_length=6, choices=settings.LANGUAGES, default=settings.LANGUAGE_CODE)
  token = models.CharField(max_length=20, unique=True)
  face_recipe = models.CharField(max_length=255, blank=True)
  access_level = models.PositiveSmallIntegerField(default=AccessLevel.User.value, choices=(
    (AccessLevel.User.value, 'User'),
    (AccessLevel.Moderator.value, 'Moderator'),
    (AccessLevel.Administrator.value, 'Administrator'),
    (AccessLevel.Superuser.value, 'Superuser'),
  ))

  USERNAME_FIELD = 'email'
  REQUIRED_FIELDS = ['nickname', 'timezone_name', 'language_code']

  objects = UserManager()

  class Meta:
    db_table = 'users'
    managed = False
    default_permissions = ()
    verbose_name = 'user'
    verbose_name_plural = 'users'

  def get_full_name(self):
    return self.nickname

  def get_short_name(self):
    return self.nickname

  def save(self, *args, **kwargs):
    if not self.token:
      self.token = User.objects.make_random_password(length=20)
    super().save(*args, **kwargs)

  # django.contrib.admin
  @property
  def is_staff(self):
    return self.access_level == User.AccessLevel.Administrator.value or self.access_level == User.AccessLevel.Superuser.value

  def has_perm(self, perm, obj=None):
    return True

  def has_module_perms(self, app_label):
    return True
