from django.contrib.auth import login, authenticate
from django.contrib.auth.decorators import login_required
from django.core.urlresolvers import reverse
from django.http import HttpResponseRedirect
from django.shortcuts import render
from django.utils import timezone
import pytz
from ossm.api import fetch
from .forms import UserCreationForm


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
      user = authenticate(
        username=form.cleaned_data['email'],
        password=form.cleaned_data['password']
      )
      login(request, user)
      return HttpResponseRedirect(reverse('user-detail', args=[user.pk]))
  else:
    form = UserCreationForm()
  return render(request, 'registration/signup.html', {'form': form})


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
