FROM falcosecurity/falco:0.18.0
LABEL description "Wazuh Agent"
LABEL maintainer "NoEnv"
LABEL maintainer="friquet@gmail.com"

# set noninteractive installation
ARG DEBIAN_FRONTEND=noninteractive
ENV TERM xterm
ENV LANG C.UTF-8
ENV SYSDIG_REPOSITORY stable
ENV SYSDIG_HOST_ROOT /host

RUN apt -y update && \
    apt --fix-broken install -y && \
    apt -y install \
    build-essential \
    tzdata \
    lsb-release \
    gnupg2 \
    python3-pip \
    python3 \
    gettext \
    gzip \
    unzip \
    zip \
    bzip2 \
    awscli \
    locales \
    curl \
    telnet \
    netcat \
    nano \
    systemd \
    apt-transport-https \
    ca-certificates \
    gcc \
    git \
    libpq-dev \
    make \
    python\
    python-dev \
    software-properties-common   

RUN apt install apt-file -y && \
    apt-file update && \
    # install setup tools & pip
    curl https://bitbucket.org/pypa/setuptools/downloads/ez_setup.py | python - && \
    curl https://bootstrap.pypa.io/get-pip.py | python -

RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu xenial stable" && \
    # add repo to repolist.
    echo "deb https://packages.wazuh.com/3.x/apt/ stable main" | tee /etc/apt/sources.list.d/wazuh.list


RUN apt update && \
    #installing pip for docker.
    pip install --upgrade pip && \
    pip install --no-cache-dir docker docker-py && \
    pip3 install --no-cache-dir docker docker-py && \
    apt-get install docker-ce-cli wazuh-agent=3.10.2-1 -y && \
    apt-get clean && \
    apt autoremove --purge -y && \
    rm -rf /var/lib/apt/lists/*

COPY agent /agent   
COPY agent/falco.yaml  etc/falco/
COPY agent/falcolog /etc/logrotate.d/falcolog

ENTRYPOINT ["/agent/entrypoint.sh"]