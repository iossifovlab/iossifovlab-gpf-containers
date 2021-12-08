FROM amd64/ubuntu:20.04

SHELL ["/bin/bash", "-c"]

RUN DEBIAN_FRONTEND=noninteractive apt-get update --fix-missing && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential gcc vim wget curl git libgl1-mesa-glx apache2 sudo && \
	apt-get clean

RUN mkdir -p /root/.conda/

RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-2019.10-Linux-x86_64.sh -O /anaconda.sh && \
    /bin/bash /anaconda.sh -b -p /opt/conda && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/ && \
    rm /anaconda.sh

RUN /opt/conda/bin/conda init bash

ENV PATH /opt/conda/bin:$PATH

RUN pip install beautifulsoup4

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -

RUN apt install -y nodejs

RUN npm install -g @angular/cli
# RUN npm install -g protractor

RUN mkdir /.npm && chown -R 1000:1000 /.npm
RUN mkdir /.config && chown -R 1000:1000 /.config

RUN mkdir -p ~/.npm && chown -R 1000:1000 ~/.npm
# RUN chown -R `whoami` /usr/local/lib/node_modules

RUN mkdir -p /work && chown -R 1000:1000 /work

WORKDIR /work

CMD ["/bin/bash"]
