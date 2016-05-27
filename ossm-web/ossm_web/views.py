from django.contrib.auth.decorators import login_required
from django.contrib.auth.forms import AuthenticationForm
from django.shortcuts import render
from django.utils import timezone
import slackinviter


def index_view(request):
  login_form = AuthenticationForm()
  return render(request, 'index.html', {'login_form': login_form})


@login_required
def invite_to_slack_view(request):
  if request.method == 'POST': #pragma: no cover
    user = request.user
    context = {}
    try:
      slackinviter.invite(user.email, user.nickname, None)
      context['success'] = True
    except slackinviter.InvalidEmailAddressException: context['error'] = 'invalid_email'
    except slackinviter.AlreadyInvitedException:       context['error'] = 'already_invited'
    except slackinviter.AlreadyInTeamException:       context['error'] = 'already_in_team'
    except slackinviter.SlackException:               context['error'] = 'misc'
    return render(request, 'slack_invite.html', context)
  return render(request, 'slack_invite.html')
