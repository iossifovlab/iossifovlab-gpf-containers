# The build-stage image:
FROM condaforge/mambaforge:latest

RUN mkdir conda-channel
COPY conda-channel /conda-channel/

RUN mamba update -y -n base -c conda-forge -y mamba
RUN mamba install -y -n base -c conda-forge conda-pack=0.8.1

RUN mamba create -n gpf -y
RUN mamba install -y -n gpf \
    -c conda-forge \
    -c bioconda \
    -c file:///conda-channel \
    -c iossifovlab \
    gpf_dae gpf_wdae gpf_rest_client gpf_federation
