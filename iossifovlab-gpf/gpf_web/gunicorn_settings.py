# flake8: noqa
import os
from .settings import *  # type: ignore

STUDIES_EAGER_LOADING = True

CSRF_TRUSTED_ORIGINS = os.environ.get("WDAE_PUBLIC_HOSTNAME", "").split(",")

