from django.conf import settings
from django.contrib.auth import login, authenticate
from django.contrib.auth.decorators import login_required
from django.contrib.sites.shortcuts import get_current_site
from django.core.mail import send_mail
from django.core.urlresolvers import reverse
from django.http import HttpResponseRedirect
from django.shortcuts import render
from django.template.loader import render_to_string
from django.utils import timezone
import pytz
from ossm.api import fetch
from .forms import UserCreationForm
from .models import User


@login_required
def redirect_to_logged_in_user_view(request):
  return HttpResponseRedirect(reverse('user-detail', args=[request.user.pk]))


def create_user_view(request):
  if request.user.is_authenticated():
    return HttpResponseRedirect(reverse('user-detail', args=[request.user.pk]))
  if request.method == 'POST':
    form = UserCreationForm(request.POST)
    if form.is_valid():
      user = form.save()
      user.is_active = False
      # Verification email
      user.generate_verification_code()
      site = get_current_site(request)
      c = {
        'user': user,
        'email': user.email,
        'code': user.verification_code,
        'domain': site.domain,
        'protocol': 'https' if request.is_secure() else 'http'
      }
      send_mail(
        render_to_string('registration/verification_subject.txt', c),
        render_to_string('registration/verification_email.txt', c),
        settings.DEFAULT_FROM_EMAIL,
        [user.email],
        html_message=render_to_string('registration/verification_email.html', c),
      )
      return HttpResponseRedirect(reverse('verify-notice'))
  else:
    form = UserCreationForm()
  return render(request, 'registration/signup.html', {'form': form})


def verify_view(request, pk=None, code=None):
  # Logged in user, go straight to their profile page.
  if request.user.is_authenticated():
    return HttpResponseRedirect(reverse('user-detail', args=[request.user.pk]))
  if pk and code:
    user = User.objects.get(pk=pk)
    # If they are already verified, go straight to login page.
    if user.verification_code == None:
      return HttpResponseRedirect(reverse('login'))
    # Try to verify them
    if user.verify(code):
      return render(request, 'registration/verify_complete.html', {'success': True})
    return render(request, 'registration/verify_complete.html', {'success': False})
  return render(request, 'registration/verify_notice.html')


@login_required
def list_users_view(request):
  data = fetch('user/list/', request.user)
  return render(request, 'ossm_auth/user_list.html', {
    'users': data['users']
  })


@login_required
def user_detail_view(request, pk=None):
  context = fetch('user/{}/'.format(pk), request.user)
  # Add a local time
  context['localTime'] = timezone.now().astimezone(pytz.timezone(context['user']['timezoneName']))
  # Since Django injects the currently logged-in user as 'user' to the context,
  # I need to rename my user in data.
  context['profileUser'] = context['user']
  del(context['user'])
  return render(request, 'ossm_auth/user_detail.html', context)
