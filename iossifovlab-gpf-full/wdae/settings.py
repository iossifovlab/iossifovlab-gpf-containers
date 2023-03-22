# flake8: noqa
import os
from .default_settings import *  # type: ignore  NOSONAR



STUDIES_EAGER_LOADING = False


''' Set these for production'''
#
PHENO_BROWSER_BASE_URL = "/gpf19/static/"

# WDAE_PUBLIC_HOSTNAME = os.environ.get("WDAE_PUBLIC_HOSTNAME")
WDAE_PREFIX = os.environ.get("WDAE_PREFIX")

LOGIN_URL = f"/{WDAE_PREFIX}/accounts/login/"
FORCE_SCRIPT_NAME = f"/{WDAE_PREFIX}"


STATIC_ROOT = '/site/gpf/static'
