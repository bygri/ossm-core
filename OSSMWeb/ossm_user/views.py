from django.http import HttpResponseRedirect, HttpResponseNotFound
from django.conf import settings
from django.contrib.sites.shortcuts import get_current_site
from django.core.urlresolvers import reverse
from django.core.mail import send_mail
from django.shortcuts import render
from django.template.loader import render_to_string
import ossm_api
from .auth import Auth, login_required, anonymous_required
from .forms import LoginForm, SignupForm, ChangePasswordForm, ResetPasswordForm, EditProfileForm


@anonymous_required
def user_create(request):
  if request.method == 'POST':
    form = SignupForm(request.POST)
    if form.is_valid():
      # Create a user with the form data
      data={
        'email': form.cleaned_data['email'],
        'password': form.cleaned_data['password'],
        'timezone': form.cleaned_data['timezone'],
        'language': form.cleaned_data['language'],
        'nickname': form.cleaned_data['nickname'],
      }
      r = ossm_api.post('/user/create', data=data)
      if r.status_code == 201:
        # User is created and awaits verification. Send the verification mail, then redirect to the
        # verification info landing page.
        j = r.json()['data']
        c = {
          'email': form.cleaned_data['email'],
          'pk': j['pk'],
          'code': j['verificationCode'],
          'domain': get_current_site(request).domain,
          'protocol': 'https' if request.is_secure() else 'http'
        }
        send_mail(
          render_to_string('user/verification_subject.txt', c),
          render_to_string('user/verification_email.txt', c),
          settings.DEFAULT_FROM_EMAIL,
          [form.cleaned_data['email']],
          html_message=render_to_string('user/verification_email.html', c),
        )
        return HttpResponseRedirect(reverse('user:verify'))
      elif r.status_code == 400:
        j = r.json()
        if j['reason'] == 'DUPLICATE_KEY':
          if j['field'] == 'email':
            form.add_error('email', 'User already exists with this email.')
          elif j['field'] == 'nickname':
            form.add_error('nickname', 'User already exists with this nickname.')
        elif j['reason'] == 'INVALID_INPUT':
          for (name, code) in j['fields']:
            if name == 'email' and code == 'LENGTH':
              form.add_error('email', 'Must be 255 characters or less.')
            if name == 'email' and code == 'EMAIL':
              form.add_error('email', 'Does not appear to be a valid email address.')
            if name == 'password' and code == 'LENGTH':
              form.add_error('password', 'Must be 8 characters or more.')
            if name == 'timezoneName' and code == 'LENGTH':
              # TODO: message the admin
              form.add_error('timezone', 'Internal server error. Try another timezone.')
            if name == 'nickname' and code == 'LENGTH':
              form.add_error('nickname', 'Must be 255 characters or less.')
            if name == 'nickname' and code == 'CHARACTERS':
              form.add_error('nickname', 'Must contain only letters, numbers, spaces, hyphens and underscores.')
        else:
          return 'shit, unhandled error: {}'.format(j['error'])
      else:
        return 'Invalid status code, bah {}'.format(r.status_code)
  else:
    form = SignupForm()
  return render(request, 'user/signup.html', {'form': form})


@anonymous_required
def user_verify(request):
  # If query params 'code' and 'pk', then try to verify.
  if 'code' in request.GET and 'pk' in request.GET:
    data={
      'code': request.GET.get('code')
    }
    r = ossm_api.post('/user/verify/{}'.format(request.GET.get('pk')), data=data)
    if r.status_code == 204:
      # Verified!
      return render(request, 'user/verify_complete.html', {'success': True})
    else:
      return render(request, 'user/verify_complete.html', {'success': False})
  # If no query params, then we tell the user they need to be verified.
  return render(request, 'user/verify_notice.html')


@anonymous_required
def user_login(request):
  if request.method == 'POST':
    form = LoginForm(request.POST)
    if form.is_valid():
      # Ask the API for authentication
      data={
        'email': form.cleaned_data['email'],
        'password': form.cleaned_data['password']
      }
      r = ossm_api.post('/user/authenticate', data=data)
      if r.status_code == 200:
        # Valid authentication!
        j = r.json()['data']
        Auth.login(request, j['pk'], j['authToken'])
        Auth.refresh(request)
        return HttpResponseRedirect(reverse('user:detail_self'))
      elif r.status_code == 401:
        return render(request, 'user/login.html', {'form': form, 'authentication_failed': True})
      else:
        return 'invalid status code bruv {}'.format(r.status_code)
  else:
    form = LoginForm()
  return render(request, 'user/login.html', {'form': form})


def user_logout(request):
  Auth.logout(request)
  return render(request, 'user/logged_out.html')


@login_required
def user_change_password(request):
  if request.method == 'POST':
    form = ChangePasswordForm(request.POST)
    if form.is_valid():
      r = ossm_api.post('/user/changePassword', headers={'Authorization': Auth(request).token}, data={
        'oldPassword': form.cleaned_data['old_password'],
        'newPassword': form.cleaned_data['new_password1']
      })
      if r.status_code == 204:
        return render(request, 'user/password_change_done.html')
      elif r.status_code == 403:
        form.add_error('old_password', 'Your old password did not match.')
      elif r.status_code == 400:
        j = r.json()
        if j['reason'] == 'DUPLICATE_KEY':
          if j['field'] == 'email':
            form.add_error('email', 'User already exists with this email.')
          elif j['field'] == 'nickname':
            form.add_error('nickname', 'User already exists with this nickname.')
        elif j['reason'] == 'INVALID_INPUT':
          for (name, code) in j['fields']:
            if name == 'password' and code == 'LENGTH':
              form.add_error('new_password1', 'Must be 8 characters or more.')
      return render(request, 'user/password_change_form.html', {'form': form})
  else:
    form = ChangePasswordForm()
  return render(request, 'user/password_change_form.html', {'form': form})


@anonymous_required
def user_reset_password(request):
  if request.method == 'POST':
    form = ResetPasswordForm(request.POST)
    if form.is_valid():
      # TODO: we don't do this yet
      return render(request, 'user/password_reset_form.html', {'form': form})
  else:
    form = ResetPasswordForm()
  return render(request, 'user/password_reset_form.html', {'form': form})


@login_required
def user_api_settings(request):
  return 'api token'


@login_required
def user_detail_self(request):
  return HttpResponseRedirect(reverse('user:detail', kwargs={'pk': Auth(request).user_pk}))


@login_required
def user_detail(request, pk):
  r = ossm_api.get('/user/{}'.format(pk), headers={'Authorization': Auth(request).token})
  if r.status_code == 404:
    return HttpResponseNotFound()
  j = r.json()['data']
  return render(request, 'user/user_detail.html', {'user': {
    'pk': j['pk'],
    'is_active': j['isActive'],
    'access_level': j['accessLevel'],
    'nickname': j['nickname'],
    'timezone': j['timezone'],
    'language': j['language'],
    'date_created': j['dateCreated'],
    'last_login': j['lastLogin'],
  }})


@login_required
def user_edit_self(request):
  if request.method == 'POST':
    form = EditProfileForm(request.POST)
    if form.is_valid():
      r = ossm_api.post('/user/edit', headers={'Authorization': Auth(request).token}, data={
        'timezone': form.cleaned_data['timezone'],
        'language': form.cleaned_data['language'],
        'nickname': form.cleaned_data['nickname'],
        'email': form.cleaned_data['email'],
      })
      if r.status_code == 204:
        Auth.refresh(request)
        return HttpResponseRedirect(reverse('user:detail_self'))
      elif r.status_code == 400:
        j = r.json()
        if j['reason'] == 'DUPLICATE_KEY':
          if j['field'] == 'nickname':
            form.add_error('nickname', 'User already exists with this nickname.')
        elif j['reason'] == 'INVALID_INPUT':
          print('problems are {}'.format(j))
          for (name, code) in j['fields']:
            if name == 'password' and code == 'LENGTH':
              form.add_error('new_password1', 'Must be 8 characters or more.')
      return render(request, 'user/profile_edit.html', {'form': form})
  else:
    # Pre-fill form with user data
    user = Auth(request)
    r = ossm_api.get('/user/{}'.format(user.user_pk), headers={'Authorization': user.token})
    if r.status_code == 404:
      return HttpResponseNotFound()
    j = r.json()['data']
    form = EditProfileForm(initial={
      'nickname': j['nickname'],
      'email': j['email'],
      'timezone': j['timezone'],
      'language': j['language'],
    })
  return render(request, 'user/profile_edit.html', {'form': form})
