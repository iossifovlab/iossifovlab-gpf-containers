# The build-stage image:
FROM condaforge/mambaforge:latest

RUN mkdir conda-channel
COPY conda-channel /conda-channel/

RUN mamba install -y -n base \
    -c conda-forge \
    conda-pack=0.7

RUN cd /opt/conda/pkgs/ && wget -c -q https://pkgs.seqpipe.org/linux64/hadoop-3.3.6-14.tar.bz2

RUN mamba create -n gpf -y
RUN mamba install -y -n gpf \
    -c conda-forge \
    -c bioconda \
    -c file:///conda-channel \
    -c iossifovlab \
    gpf_dae gpf_wdae gpf_rest_client gpf_federation

# RUN mkdir -p /code
# WORKDIR /code
# COPY gpf /code

# RUN cd /code/dae && mamba run --no-capture-output -n gpf \
# 	pip install .

# RUN cd /code/wdae && mamba run --no-capture-output -n gpf \
# 	pip install .



