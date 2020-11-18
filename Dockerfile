FROM jenkins/jenkins

USER root
RUN apt-get -y update && \
    apt-get -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common

# Install docker-ce-cli
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN apt-key fingerprint 0EBFCD88
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get -y install docker-ce-cli

# Install docker-compose
RUN curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose && \
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Install python
# RUN yes | apt install build-essential zlib1g-dev \
#         libncurses5-dev libgdbm-dev libnss3-dev \
#         libssl-dev libreadline-dev libffi-dev curl && \
#     wget https://www.python.org/ftp/python/3.9.0/Python-3.9.0.tar.xz && \
#     tar -xf Python-3.9.0.tar.xz && \
#     cd Python-3.9.0 && \
#     ./configure && \
#     make install && \
#     python3 --version

# Install NodeJS
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    yes | apt install nodejs

# Install Google Cloud SDK
ENV CLOUDSDK_PYTHON="/usr/bin/python3"
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && apt-get update -y && apt-get install google-cloud-sdk -y

USER jenkins