import os
import sys

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "wdae.gunicorn_settings")

from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()
