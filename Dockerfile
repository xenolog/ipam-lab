FROM alpine:3.9

MAINTAINER Sergey Vasilenko <stalk@makeworld.ru>

#RUN apk update && apk --no-cache add \
RUN apk --no-cache add \
        sudo \
        curl \
        python3 \
        openssl \
        ca-certificates \
        sshpass \
        openssh-client \
        rsync && \
    apk --no-cache add --virtual build-dependencies \
        python3-dev \
        libffi-dev \
        openssl-dev \
        build-base && \
    pip3 install --upgrade cffi && \
    pip3 install netaddr ansible==2.7.11 ansible-ssh && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/*

RUN mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts

CMD [ "ansible-playbook", "--version" ]

###