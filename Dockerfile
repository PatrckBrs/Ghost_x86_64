# New version update 0.11.4
FROM node:6.9-wheezy

LABEL maintainer "Patrick Brunias <patrick@brunias.org>"

ENV GHOST_VERSION=1.5.0
ENV NPM_CONFIG_LOGLEVEL warn

USER root
# Update sources && install packages
RUN DEBIAN_FRONTEND=noninteractive ;\
apt-get update && \
apt-get install --assume-yes unzip

WORKDIR /var/www/
RUN mkdir ghost && \
wget https://github.com/TryGhost/Ghost/releases/download/${GHOST_VERSION}/Ghost-${GHOST_VERSION}.zip && \
unzip Ghost-${GHOST_VERSION}.zip -d ghost

RUN apt-get -y remove wget unzip && \
    rm -rf /var/lib/apt/lists/*

RUN addgroup www-data
RUN adduser ghost -G www-data -S /bin/bash
RUN chown ghost:www-data .

RUN ghost install local --no-start

USER ghost

WORKDIR /var/www/ghost

RUN ghost install local --no-start

EXPOSE 2368
EXPOSE 2369

VOLUME ["/var/www/ghost/content/apps"]
VOLUME ["/var/www/ghost/content/data"]
VOLUME ["/var/www/ghost/content/images"]

ENV NODE_ENV production
RUN sed -ie s/127.0.0.1/0.0.0.0/g config.development.json

CMD ["ghost", "run", "--development", "--ip", "0.0.0.0"]
