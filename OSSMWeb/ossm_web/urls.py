from django.conf.urls import url
from .views import index_view, invite_to_slack_view


urlpatterns = [
  url(r'^$', index_view, name='index'),
  url(r'^slack/invite/$', invite_to_slack_view, name='slack-invite'),
]
