import os
import sys

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "gpf_web.settings")

from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()
