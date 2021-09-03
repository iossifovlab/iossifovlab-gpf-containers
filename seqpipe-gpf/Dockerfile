FROM registry.seqpipe.org/seqpipe-anaconda-base:master_5ef70d4-124

RUN apt-get update --fix-missing && \
	apt-get install -y build-essential gcc vim wget curl git libgl1-mesa-glx \
		supervisor less vim \
    	inetutils-ping net-tools apt-utils \
		mysql-client && \
		apt-get clean

ADD gpf/environment.yml /
ADD gpf/dev-environment.yml /

RUN /opt/conda/bin/conda env create --name gpf --file /environment.yml
RUN /opt/conda/bin/conda env update --name gpf --file /dev-environment.yml --prune

RUN conda install -n gpf -c defaults -c conda-forge gunicorn mysqlclient
RUN conda install -n gpf -c defaults -c conda-forge -c anaconda mysql-connector-python
RUN conda install -n gpf -c defaults -c conda-forge raven

RUN conda update -n base -c defaults conda

RUN mkdir -p /code
WORKDIR /code
COPY gpf /code

# GPF ENV
ENV PATH /opt/conda/envs/gpf/bin:$PATH

# HADOOP CONFIG
ENV JAVA_HOME /opt/conda/envs/gpf
ENV HADOOP_HOME /opt/conda/envs/gpf
ENV HADOOP_CONF_DIR /opt/conda/envs/gpf/etc/hadoop


WORKDIR /code/wdae

COPY ./wdae.wsgi /code/wdae/wdae/wdae/wsgi.py

COPY ./gunicorn.wsgi /code/wdae/wdae/wdae/gunicorn_wsgi.py

COPY ./settings.py /code/wdae/wdae/wdae/settings.py
COPY ./gunicorn_settings.py /code/wdae/wdae/wdae/gunicorn_settings.py

RUN cd /code/dae && pip install . && cd /code/wdae && pip install . && cd /

RUN mkdir -p /logs

# RUN ln -s /code/wdae/wdae/wdaemanage.py /bin/wdaemanage.py
# CMD /code/wdae/wdae/wdaemanage.py migrate && /code/start_gunicorn.sh

ADD ./supervisor/supervisord.conf /etc/
ADD ./bin/supervisord-bootstrap.sh /
ADD ./bin/wait-for-it.sh /
RUN chmod +x /*.sh

RUN mkdir -p /data

EXPOSE 9001 9002

ENTRYPOINT ["supervisord", "-c", "/etc/supervisord.conf", "-n"]

