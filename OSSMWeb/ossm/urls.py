from django.conf.urls import url, include


urlpatterns = [
  url(r'^user/', include('ossm_user.urls', namespace='user')),
  url(r'', include('ossm_site.urls', namespace='site')),
  url(r'community/', include('ossm_community.urls', namespace='community')),
]
