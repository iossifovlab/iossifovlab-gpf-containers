ARG REGISTRY=""
ARG BASE_IMAGE_TAG=latest

FROM ${REGISTRY}iossifovlab-gpf-base:${BASE_IMAGE_TAG} AS build

RUN conda-pack -n gpf -o /tmp/gpf.tar && \
  mkdir /gpf && cd /gpf && tar xf /tmp/gpf.tar && \
  rm /tmp/gpf.tar

RUN /gpf/bin/conda-unpack

FROM ${REGISTRY}iossifovlab-gpfjs-base:${BASE_IMAGE_TAG} AS runtime

# Copy /gpf environment from the previous stage:
COPY --from=build /gpf /gpf


ARG PYTHON_VERSION="3.12"

# configure gpf_web
COPY ./gpf_web/wdae.wsgi /gpf/lib/python${PYTHON_VERSION}/site-packages/gpf_web/wsgi.py
COPY ./gpf_web/gunicorn.wsgi /gpf/lib/python${PYTHON_VERSION}/site-packages/gpf_web/gunicorn_wsgi.py
COPY ./gpf_web/settings.py /gpf/lib/python${PYTHON_VERSION}/site-packages/gpf_web/settings.py
COPY ./gpf_web/gunicorn_settings.py /gpf/lib/python${PYTHON_VERSION}/site-packages/gpf_web/gunicorn_settings.py

# When image is run, run the code with the environment
# activated:
RUN echo "source /gpf/bin/activate" >> /etc/bash.bashrc
# Explicitly add gpf/bin to the path to aid certain tools 
# (like dask)in finding the needed executables
ENV PATH /gpf/bin:$PATH

EXPOSE 80 443

ENTRYPOINT ["supervisord", "-c", "/etc/supervisord.conf", "-n"]
