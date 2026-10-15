FROM jenkins/jenkins:lts

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates tar \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL --retry 5 --retry-all-errors \
    https://download.docker.com/linux/static/stable/x86_64/docker-28.3.2.tgz \
    -o /tmp/docker.tgz \
    && tar -xzf /tmp/docker.tgz -C /tmp \
    && install -m 0755 /tmp/docker/docker /usr/local/bin/docker \
    && rm -rf /tmp/docker /tmp/docker.tgz

RUN curl --http1.1 -fsSL --retry 5 --retry-all-errors \
    https://dl.k8s.io/release/v1.32.2/bin/linux/amd64/kubectl \
    -o /usr/local/bin/kubectl \
    && chmod 0755 /usr/local/bin/kubectl

USER jenkins
