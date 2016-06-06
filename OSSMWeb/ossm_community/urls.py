from django.conf.urls import url
from . import views


urlpatterns = [
  url(r'^slack-invite/$', views.invite_to_slack, name='slack_invite'),
  url(r'^slack/$', views.open_slack, name='slack'),
]
