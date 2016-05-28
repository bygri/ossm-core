from django.conf.urls import url, include
from .views import redirect_to_logged_in_user_view, create_user_view, list_users_view, user_detail_view, verify_view


urlpatterns = [
  url(r'^$', redirect_to_logged_in_user_view, name='my-user-detail'),
  url(r'list/$', list_users_view, name='user-list'),
  url(r'^signup/$', create_user_view, name='user-create'),
  url(r'^verify/$', verify_view, name='verify-notice'),
  url(r'^verify/(?P<pk>\d+)/(?P<code>\w+)/', verify_view, name='verify-confirm'),
  url(r'^(?P<pk>\d+)/$', user_detail_view, name='user-detail'),
  url(r'^', include('django.contrib.auth.urls')),
]
