# The build-stage image:
ARG REGISTRY=""
ARG BASE_IMAGE_TAG=latest
FROM ${REGISTRY}iossifovlab-gpf-base:${BASE_IMAGE_TAG}

RUN cd /opt/conda/pkgs/ && wget -c -q https://pkgs.seqpipe.org/linux64/hadoop-3.3.6-14.tar.bz2

RUN mamba install -y -n gpf \
    -c conda-forge \
    -c bioconda \
    -c file:///conda-channel \
    -c iossifovlab \
    gpf_impala_storage


SHELL ["/bin/bash", "-c"]


