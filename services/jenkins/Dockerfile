FROM jenkins/jenkins:lts

USER root

RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get update -qq \
 && apt-get install -qqy apt-transport-https \
 && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN . /etc/os-release \
 && echo "deb [arch=amd64] https://download.docker.com/linux/debian $VERSION_CODENAME stable" >/etc/apt/sources.list.d/docker.list

RUN groupadd -g 998 docker
RUN adduser jenkins docker

RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get update -qq \
 && apt-get install -qqy docker-ce \
 && rm -rf /var/lib/apt/lists/*

RUN OS=$(uname -s | tr '[:upper:]' '[:lower:]') \
 && ARCH=$(uname -m) \
 && curl -L "https://github.com/docker/compose/releases/download/2.2.3/docker-compose-${OS}-${ARCH}" -o /usr/local/bin/docker-compose \
 && chmod +x /usr/local/bin/docker-compose

USER jenkins
