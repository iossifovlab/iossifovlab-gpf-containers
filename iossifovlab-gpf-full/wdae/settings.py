# flake8: noqa
import os
from .default_settings import *  # type: ignore  NOSONAR


SECRET_KEY = os.environ.get("WDAE_SECRET_KEY")

STUDIES_EAGER_LOADING = False


if os.environ.get("SENTRY_API_URL", None):
    import raven

    INSTALLED_APPS += [
        'raven.contrib.django.raven_compat',
    ]

    RAVEN_CONFIG = {
        'dsn': os.environ.get("SENTRY_API_URL", None),
        # If you are using git, you can also automatically configure the
        # release based on the git info.
        # 'release': raven.fetch_git_sha(os.path.dirname(__file__)),
    }



DEBUG = os.environ.get("WDAE_DEBUG", "False") == "True"

''' Set these for production'''
#
PHENO_BROWSER_BASE_URL = "/gpf19/static/"

EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
if os.environ.get("WDAE_EMAIL_HOST", None):
    EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
    EMAIL_HOST = os.environ.get("WDAE_EMAIL_HOST", None)

    DEFAULT_FROM_EMAIL = os.environ.get("WDAE_DEFAULT_FROM_EMAIL", None)
    EMAIL_HOST_USER = os.environ.get("WDAE_EMAIL_HOST_USER", None)
    EMAIL_HOST_PASSWORD = os.environ.get("WDAE_EMAIL_HOST_PASSWORD", None)

    EMAIL_PORT = os.environ.get("WDAE_EMAIL_PORT", None)
    if EMAIL_PORT is not None:
        EMAIL_PORT = int(EMAIL_PORT)

    EMAIL_SUBJECT_PREFIX = '[GPF] '
    EMAIL_USE_TLS = True


WDAE_PUBLIC_HOSTNAME = os.environ.get("WDAE_PUBLIC_HOSTNAME")
WDAE_PREFIX = os.environ.get("WDAE_PREFIX")

LOGIN_URL = f"/{WDAE_PREFIX}/accounts/login/"
FORCE_SCRIPT_NAME = f"/{WDAE_PREFIX}"

EMAIL_VERIFICATION_HOST = f"https://{ WDAE_PUBLIC_HOSTNAME }/{ WDAE_PREFIX }"
EMAIL_VERIFICATION_PATH = '/validate/{}'
# EMAIL_OVERRIDE = ['lubomir.chorbadjiev@gmail.com']

DEFAULT_RENDERER_CLASSES = [
    "rest_framework.renderers.JSONRenderer",
]

if DEBUG:
    DEFAULT_RENDERER_CLASSES = DEFAULT_RENDERER_CLASSES + \
        ["rest_framework.renderers.BrowsableAPIRenderer", ]

REST_FRAMEWORK["DEFAULT_RENDERER_CLASSES"] = DEFAULT_RENDERER_CLASSES


DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': os.environ.get("WDAE_DB_NAME"),
        'USER': os.environ.get("WDAE_DB_USER"),
        'PASSWORD': os.environ.get("WDAE_DB_PASSWORD"),
        'HOST': os.environ.get("WDAE_DB_HOST"),
        'PORT': os.environ.get("WDAE_DB_PORT"),
    }
}

ALLOWED_HOSTS = [
    os.environ.get("WDAE_ALLOWED_HOST")
]

TIME_ZONE = "US/Eastern"

STATIC_ROOT = '/site/gpf/static'


LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "filters": {
        "require_debug_false": {"()": "django.utils.log.RequireDebugFalse"}
    },
    "formatters": {
        "verbose": {
            "format": "%(levelname)s %(asctime)s %(module)s %(process)d "
            "%(thread)d %(message)s"
        },
        "simple": {"format": "%(levelname)s %(message)s"},
    },
    "handlers": {
        "console": {
            "level": "DEBUG",
            "class": "logging.StreamHandler",
            "formatter": "verbose",
        },
        "mail_admins": {
            "level": "ERROR",
            "filters": ["require_debug_false"],
            "class": "django.utils.log.AdminEmailHandler",
        },
        # Log to a text file that can be rotated by logrotate
        "logfile": {
            "class": "logging.handlers.WatchedFileHandler",
            'filename': '/logs/wdae-api.log',
            "filters": ["require_debug_false"],
            "formatter": "verbose",
        },
        "logdebug": {
            "class": "logging.handlers.WatchedFileHandler",
            'filename': '/logs/wdae-debug.log',
            "formatter": "verbose",
        },
    },
    "loggers": {
        "django": {
            "handlers": ["logfile", "logdebug"],
            "propagate": True,
            "level": "INFO",
        },
        'django.request': {
            'handlers': ['logfile', "logdebug"],
            'level': 'INFO',
            'propagate': True,
        },
        "wdae.api": {
            "handlers": ["logfile", "logdebug"],
            "level": "DEBUG",
            "propagate": True,
        },
        "impala": {
            "handlers": ["console", "logdebug"],  # 'logfile'],
            "level": "INFO",
            "propagate": True,
        },
        "matplotlib": {
            "handlers": ["console", "logdebug"],  # 'logfile'],
            "level": "INFO",
            "propagate": True,
        },
        "": {
            "handlers": ["console", "logdebug"],  # 'logfile'],
            "level": "DEBUG",
            "propagate": True,
        },
    },
}

