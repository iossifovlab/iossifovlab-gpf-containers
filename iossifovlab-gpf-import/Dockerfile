# The build-stage image:
ARG REGISTRY=""
ARG BASE_IMAGE_TAG=latest
FROM ${REGISTRY}iossifovlab-gpf-base:${BASE_IMAGE_TAG}

RUN mamba install -y -n gpf \
    -c conda-forge \
    -c bioconda \
    -c file:///conda-channel \
    -c iossifovlab \
    gpf_impala_storage \
    hadoop=3.1.2 \
    dask-kubernetes=2023.3.1 \
    dask-jobqueue=0.8.1


SHELL ["/bin/bash", "-c"]


