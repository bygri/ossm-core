from django.conf.urls import url, include
from django.contrib import admin


urlpatterns = [
  url(r'^user/', include('ossm_auth.urls')),
  url(r'^admin/', admin.site.urls),
  url(r'', include('ossm_web.urls')),
]
