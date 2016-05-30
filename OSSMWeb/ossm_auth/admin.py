from django import forms
from django.contrib import admin
from django.contrib.auth.models import Group
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.contrib.auth.forms import ReadOnlyPasswordHashField
from .models import User


class UserChangeForm(forms.ModelForm):
  password = ReadOnlyPasswordHashField()

  class Meta:
    model = User
    fields = ('email', 'password', 'is_active',)

  def clean_password(self): #pragma: no cover
    # as per Django docs on customising auth
    return self.initial['password']


class UserAdmin(BaseUserAdmin):
  form = UserChangeForm
  list_display = ('email', 'nickname', 'access_level', 'language_code')
  list_filter = ('access_level',)
  fieldsets = (
    (None, {'fields': ('email', 'password', 'is_active', 'access_level',)}),
    ('Personal', {'fields': ('nickname', 'timezone_name', 'language_code', 'face_recipe',)}),
  )
  search_fields = ('email',)
  ordering = ('email',)
  filter_horizontal = ()


admin.site.register(User, UserAdmin)
admin.site.unregister(Group)
