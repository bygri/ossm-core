from django import forms
from django.contrib.auth.password_validation import validate_password
from .models import User


class UserCreationForm(forms.ModelForm):
  def clean_password(self):
    value = self.cleaned_data['password']
    validate_password(value)
    return value

  class Meta:
    model = User
    fields = ['email', 'password', 'nickname', 'timezone_name', 'language_code']
    widgets = {
      'password': forms.PasswordInput(),
      'timezone_name': forms.Select(attrs={'class': 'form-control'}),
      'language_code': forms.Select(attrs={'class': 'form-control'}),
    }

  def save(self, commit=True):
    user = super().save(commit=False)
    user.set_password(self.cleaned_data['password'])
    if commit:
      user.save()
    return user
