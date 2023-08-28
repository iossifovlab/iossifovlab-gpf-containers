# The build-stage image:
ARG REGISTRY=""
ARG BASE_IMAGE_TAG=latest
FROM ${REGISTRY}iossifovlab-gpf-base:${BASE_IMAGE_TAG} AS build

RUN mamba install -y -n gpf \
    -c conda-forge \
    -c bioconda \
    -c file:///conda-channel \
    -c iossifovlab \
    gpf_impala_storage \
    gunicorn=20.1.0 \
    mysqlclient=2.0.3

RUN conda-pack -n gpf -o /tmp/gpf.tar && \
  mkdir /gpf && cd /gpf && tar xf /tmp/gpf.tar && \
  rm /tmp/gpf.tar

RUN /gpf/bin/conda-unpack


FROM ubuntu:22.04 AS runtime

# Copy /gpf environment from the previous stage:
COPY --from=build /gpf /gpf

# When image is run, run the code with the environment
# activated:
RUN echo "source /gpf/bin/activate" >> /etc/bash.bashrc
# Explicitly add gpf/bin to the path to aid certain tools 
# (like dask)in finding the needed executables
ENV PATH /gpf/bin:$PATH

SHELL ["/bin/bash", "-c"]


