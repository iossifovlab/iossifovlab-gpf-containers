# The build-stage image:
FROM continuumio/miniconda3 AS build

RUN conda install -y -c conda-forge conda-pack mamba

COPY gpf/environment.yml /

RUN mamba env create --name gpf --file /environment.yml

RUN mamba install -n gpf -c defaults -c conda-forge gunicorn=20.1.0 mysqlclient=2.0.3

RUN mkdir -p /code
WORKDIR /code
COPY gpf /code

RUN cd /code/dae && mamba run --no-capture-output -n gpf \
	pip install .

RUN cd /code/wdae && mamba run --no-capture-output -n gpf \
	pip install .

RUN conda-pack -n gpf -o /tmp/gpf.tar && \
  mkdir /gpf && cd /gpf && tar xf /tmp/gpf.tar && \
  rm /tmp/gpf.tar

RUN /gpf/bin/conda-unpack


FROM ubuntu:20.04 AS runtime

# Copy /venv from the previous stage:
COPY --from=build /gpf /gpf
COPY --from=build /code /code

# When image is run, run the code with the environment
# activated:
RUN echo "source /gpf/bin/activate" >> /etc/bash.bashrc

SHELL ["/bin/bash", "-c"]


