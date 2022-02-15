FROM nginx:stable

WORKDIR /var/tmp/nginx

ADD wovnrb.conf .
ADD scripts/startup.sh .
ADD scripts/configure_sshd.sh .

RUN apt-get update --allow-releaseinfo-change \
    && apt install --no-install-recommends -y \
      vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Setup sshd
RUN ./configure_sshd.sh

CMD ["/var/tmp/nginx/startup.sh"]
