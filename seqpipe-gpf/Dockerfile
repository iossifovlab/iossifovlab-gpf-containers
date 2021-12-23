ARG REGISTRY=""
ARG BASE_IMAGE_TAG=latest
FROM ${REGISTRY}seqpipe-anaconda-base:${BASE_IMAGE_TAG}

RUN DEBIAN_FRONTEND=noninteractive apt-get update --fix-missing && \
	DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y && \
	DEBIAN_FRONTEND=noninteractive apt-get clean

	# DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential gcc vim wget curl git libgl1-mesa-glx \
	# 	supervisor less vim \
    # 	inetutils-ping net-tools apt-utils \
	# 	mysql-client && \
	# 	apt-get clean



ADD gpf/environment.yml /
# ADD gpf/dev-environment.yml /

RUN mamba env create --name gpf --file /environment.yml
# RUN conda env update --name gpf --file /dev-environment.yml --prune


# RUN conda install -n gpf -c defaults -c conda-forge gunicorn=20.1.0 mysqlclient=2.0.3

# RUN conda update -n base -c defaults conda


RUN mkdir -p /code
WORKDIR /code
COPY gpf /code

RUN cd /code/dae && /opt/conda/bin/conda run --no-capture-output -n gpf \
	pip install .

RUN cd /code/wdae && /opt/conda/bin/conda run --no-capture-output -n gpf \
	pip install .

# # GPF ENV
# ENV PATH /opt/conda/envs/gpf/bin:$PATH

# # HADOOP CONFIG
# ENV JAVA_HOME /opt/conda/envs/gpf
# ENV HADOOP_HOME /opt/conda/envs/gpf
# ENV HADOOP_CONF_DIR /opt/conda/envs/gpf/etc/hadoop


# WORKDIR /code/wdae

# COPY ./wdae.wsgi /code/wdae/wdae/wdae/wsgi.py

# COPY ./gunicorn.wsgi /code/wdae/wdae/wdae/gunicorn_wsgi.py

# COPY ./settings.py /code/wdae/wdae/wdae/settings.py
# COPY ./gunicorn_settings.py /code/wdae/wdae/wdae/gunicorn_settings.py

# RUN cd /code/dae && pip install . && cd /code/wdae && pip install . && cd /

# RUN mkdir -p /logs

# # RUN ln -s /code/wdae/wdae/wdaemanage.py /bin/wdaemanage.py
# # CMD /code/wdae/wdae/wdaemanage.py migrate && /code/start_gunicorn.sh

# ADD ./supervisor/supervisord.conf /etc/
# ADD ./bin/supervisord-bootstrap.sh /
# ADD ./bin/wait-for-it.sh /
# RUN chmod +x /*.sh

# RUN mkdir -p /data

# EXPOSE 9001 9002

# ENTRYPOINT ["supervisord", "-c", "/etc/supervisord.conf", "-n"]

