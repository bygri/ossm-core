import requests
from django.conf import settings


class SlackException(Exception): pass
class InvalidEmailAddressException(SlackException): pass
class AlreadyInvitedException(SlackException): pass
class AlreadyInTeamException(SlackException): pass


def invite(email, first_name, last_name, channels=None, set_active=True): #pragma: no cover
  if not channels:
    channels = settings.SLACK_DEFAULT_CHANNELS
  # Post to Slack API
  url = 'https://{}.slack.com/api/users.admin.invite'.format(settings.SLACK_TEAM)
  data = {
    'email': email,
    'first_name': first_name,
    'last_name': last_name,
    'token': settings.SLACK_TOKEN,
    'set_active': set_active,
    'channels': ','.join(channels),
  }
  r = requests.post(url, data=data)
  response = r.json()
  if not response['ok']:
    # Raise an exception
    if response['error'] == 'invalid_email':
      raise InvalidEmailAddressException('Invalid email address {}'.format(email))
    elif response['error'] == 'already_invited':
      raise AlreadyInvitedException('User {} has already been invited to Slack team {}'.format(email, settings.SLACK_TEAM))
    elif response['error'] == 'already_in_team':
      raise AlreadyInTeamException('User {} already exists in Slack team {}'.format(email, settings.SLACK_TEAM))
    elif 'error' in response:
      raise SlackException('Slack invite error: {}'.format(response['error']))
    else:
      raise SlackException('Unknown Slack error: {}'.format(response))
