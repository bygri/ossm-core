from django import forms
import pytz


class LoginForm(forms.Form):
  email = forms.EmailField(label='Email', max_length=255, widget=forms.TextInput(attrs={'class': 'form-control'}))
  password = forms.CharField(label='Password', widget=forms.PasswordInput(attrs={'class': 'form-control'}))


class SignupForm(forms.Form):
  email = forms.EmailField(label='Email', max_length=255, widget=forms.TextInput(attrs={'class': 'form-control'}))
  password = forms.CharField(label='Password', widget=forms.PasswordInput(attrs={'class': 'form-control'}))
  timezone = forms.ChoiceField(label='Timezone',
    choices=[(t, t) for t in pytz.common_timezones],
    initial='Australia/Sydney', widget=forms.Select(attrs={'class': 'form-control'}))
  language = forms.ChoiceField(label='Language', choices=(
    ('en-AU', 'Australian'),
    ('en-PIRAT', 'Pirate'),
    ('sv-CHEF', 'Swedish Chef'),
  ), initial='en-AU', widget=forms.Select(attrs={'class': 'form-control'}))
  nickname = forms.CharField(max_length=40, widget=forms.TextInput(attrs={'class': 'form-control'}))


class ChangePasswordForm(forms.Form):
  old_password = forms.CharField(label='Old password', widget=forms.PasswordInput(attrs={'class': 'form-control'}))
  new_password1 = forms.CharField(label='New password', widget=forms.PasswordInput(attrs={'class': 'form-control'}))
  new_password2 = forms.CharField(label='Confirm password', widget=forms.PasswordInput(attrs={'class': 'form-control'}))

  def clean(self):
    cleaned_data = super().clean()
    p1 = self.cleaned_data.get('new_password1')
    p2 = self.cleaned_data.get('new_password2')
    if p1 != p2:
      self.add_error('new_password2', 'Passwords do not match.')


class ResetPasswordForm(forms.Form):
  email = forms.EmailField(label='Email', max_length=255, widget=forms.TextInput(attrs={'class': 'form-control'}))


class EditProfileForm(forms.Form):
  timezone = forms.ChoiceField(label='Timezone',
    choices=[(t, t) for t in pytz.common_timezones],
    initial='Australia/Sydney', widget=forms.Select(attrs={'class': 'form-control'}))
  language = forms.ChoiceField(label='Language', choices=(
    ('en-AU', 'Australian'),
    ('en-PIRAT', 'Pirate'),
    ('sv-CHEF', 'Swedish Chef'),
  ), initial='en-AU', widget=forms.Select(attrs={'class': 'form-control'}))
  email = forms.EmailField(label='Email', max_length=255, widget=forms.TextInput(attrs={'class': 'form-control'}))
  nickname = forms.CharField(max_length=40, widget=forms.TextInput(attrs={'class': 'form-control'}))
