#!/bin/bash

exec /opt/conda/bin/gunicorn \
    --preload \
    --worker-class gthread \
    --workers=1 \
    --threads=8 \
    --bind=0.0.0.0:9001 \
    --timeout=300 \
    --access-logfile /logs/access.log \
    --error-logfile /logs/error.log \
    wdae.gunicorn_wsgi:application
