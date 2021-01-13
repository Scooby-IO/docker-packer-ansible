FROM alpine:3.12

# Env setup
ENV PACKER_VERSION=1.6.6 \
    PACKER_OSNAME=linux \
    PACKER_OSARCH=amd64 \
    PACKER_DEST=/usr/local/sbin \
    ANSIBLE_VERSION=2.9

# Packer path setup
ENV PACKER_ZIPFILE=packer_${PACKER_VERSION}_${PACKER_OSNAME}_${PACKER_OSARCH}.zip

RUN echo cache_layer_kill_0

# Install packer in path
ADD https://releases.hashicorp.com/packer/${PACKER_VERSION}/${PACKER_ZIPFILE} ${PACKER_DEST}/
RUN unzip ${PACKER_DEST}/${PACKER_ZIPFILE} -d ${PACKER_DEST} && \
    rm -rf ${PACKER_DEST}/${PACKER_ZIPFILE}

RUN apk --update --no-cache add \
        ca-certificates \
        git \
        openssh-client \
        openssl \
        python3\
        py3-pip \
        py3-cryptography \
        rsync \
        sshpass

RUN apk --update add --virtual \
        .build-deps \
        python3-dev \
        libffi-dev \
        openssl-dev \
        build-base \
        curl

RUN pip install ansible==${ANSIBLE_VERSION}
RUN pip install pywinrm
RUN mkdir /etc/ansible /ansible
RUN mkdir ~/.ssh

COPY ansible.cfg /etc/ansible/ansible.cfg

RUN echo cache_layer_kill_0
COPY setupWinRm.ps1 .

# Over rides SSH Hosts Checking
RUN echo “host *” >> ~/.ssh/config &&\
    echo “StrictHostKeyChecking no” >> ~/.ssh/config
