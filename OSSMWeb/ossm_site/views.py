from ossm_user.forms import LoginForm
from django.shortcuts import render


def index(request):
  login_form = LoginForm()
  return render(request, 'site/index.html', {'login_form': login_form})
