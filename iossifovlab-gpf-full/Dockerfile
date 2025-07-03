ARG REGISTRY=""
ARG BASE_IMAGE_TAG=latest
ARG PYTHON_VERSION="3.9"

FROM ${REGISTRY}iossifovlab-gpf-import:${BASE_IMAGE_TAG} AS build

RUN conda-pack -n gpf -o /tmp/gpf.tar && \
  mkdir /gpf && cd /gpf && tar xf /tmp/gpf.tar && \
  rm /tmp/gpf.tar

RUN /gpf/bin/conda-unpack


FROM ${REGISTRY}iossifovlab-gpfjs-base:${BASE_IMAGE_TAG} AS runtime

# Copy /gpf environment from the previous stage:
COPY --from=build /gpf /gpf

ARG PYTHON_VERSION="3.12"

# configure wdae
COPY ./wdae/wdae.wsgi /gpf/lib/python${PYTHON_VERSION}/site-packages/wdae/wsgi.py
COPY ./wdae/gunicorn.wsgi /gpf/lib/python${PYTHON_VERSION}/site-packages/wdae/gunicorn_wsgi.py
COPY ./wdae/settings.py /gpf/lib/python${PYTHON_VERSION}/site-packages/wdae/settings.py
COPY ./wdae/gunicorn_settings.py /gpf/lib/python${PYTHON_VERSION}/site-packages/wdae/gunicorn_settings.py

# When image is run, run the code with the environment
# activated:
RUN echo "source /gpf/bin/activate" >> /etc/bash.bashrc
# Explicitly add gpf/bin to the path to aid certain tools 
# (like dask)in finding the needed executables
ENV PATH /gpf/bin:$PATH

EXPOSE 80 443

ENTRYPOINT ["supervisord", "-c", "/etc/supervisord.conf", "-n"]
