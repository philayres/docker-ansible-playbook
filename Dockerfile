FROM alpine:3.6

ENV ANSIBLE_VERSION 1.9.4

ENV BUILD_PACKAGES \
  bash \
  curl \
  tar \
  openssh-client \
  sshpass \
  git \
  python \
  py-boto \
  py-dateutil \
  py-httplib2 \
  py-jinja2 \
  py-paramiko \
  py-pip \
  py-setuptools \
  py-yaml \
  ca-certificates \
  iputils

RUN apk --update add --virtual build-dependencies \
  gcc \
  musl-dev \
  libffi-dev \
  openssl-dev \
  python-dev

# If installing ansible@testing
#RUN \
#	echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >> #/etc/apk/repositories

RUN set -x && \
    apk update && apk upgrade && \
    apk add --no-cache ${BUILD_PACKAGES} && \
    pip install --upgrade pip && \
    pip install python-keyczar docker-py && \
    # Cleaning up
    apk del build-dependencies && \
  	rm -rf /var/cache/apk/*

RUN \
  mkdir -p /etc/ansible/ /ansible

RUN \
  echo "[local]" >> /etc/ansible/hosts && \
  echo "localhost" >> /etc/ansible/hosts

RUN \
  addgroup normaluser && \
  adduser -S -G normaluser normaluser

RUN \
  curl -fsSL https://releases.ansible.com/ansible/ansible-${ANSIBLE_VERSION}.tar.gz -o ansible.tar.gz && \
  tar -xzf ansible.tar.gz -C /ansible --strip-components 1 && \
  rm -fr ansible.tar.gz /ansible/docs /ansible/examples /ansible/packaging

ENV ANSIBLE_ROLES_PATH /ansible/playbooks/roles
ENV PYTHONPATH /ansible/lib
ENV PATH /ansible/bin:$PATH
ENV ANSIBLE_LIBRARY /ansible/library

WORKDIR /ansible/playbooks

RUN \
#  mkdir /home/normaluser/.ssh && \
#  touch /home/normaluser/.ssh/config && \
#  chmod 700 /home/normaluser/.ssh && \

USER normaluser

ENTRYPOINT ["ansible-playbook"]
