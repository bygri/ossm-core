from django.conf.urls import url
from . import views


urlpatterns = [
  url(r'^signup/$', views.user_create, name='create'),
  url(r'^verify/$', views.user_verify, name='verify'),
  url(r'^login/$', views.user_login, name='login'),
  url(r'^logout/$', views.user_logout, name='logout'),
  url(r'^change-password/$', views.user_change_password, name='change_password'),
  url(r'^reset-password/$', views.user_reset_password, name='reset_password'),
  url(r'^api/$', views.user_api_settings, name='api_settings'),
  url(r'^$', views.user_detail_self, name='detail_self'),
  url(r'^(?P<pk>\d+)/$', views.user_detail, name='detail'),
  url(r'^edit/$', views.user_edit_self, name='edit_self'),
]
