from ossm_user.forms import LoginForm
from ossm_user.auth import Auth, login_required
from django.http import HttpResponseRedirect
from django.shortcuts import render
from . import slack


@login_required
def invite_to_slack(request):
  if request.method == 'POST': #pragma: no cover
    user = Auth(request)
    # Fetch email and nickname from API
    data = user.fetch_data(request)
    context = {}
    try:
      slack.invite(data['email'], data['nickname'], None)
      context['success'] = True
    except slack.InvalidEmailAddressException: context['error'] = 'invalid_email'
    except slack.AlreadyInvitedException:      context['error'] = 'already_invited'
    except slack.AlreadyInTeamException:       context['error'] = 'already_in_team'
    except slack.SlackException:               context['error'] = 'misc'
    return render(request, 'community/slack_invite.html', context)
  return render(request, 'community/slack_invite.html')


@login_required
def open_slack(request):
  return HttpResponseRedirect('https://ossm.slack.com')
