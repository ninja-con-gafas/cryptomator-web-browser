ARG VERSION=0.6.2

FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y curl unzip fuse3 && \
    rm -rf /var/lib/apt/lists/*

RUN sed -i 's/#user_allow_other/user_allow_other/g' /etc/fuse.conf

ARG VERSION

RUN curl -L "https://github.com/cryptomator/cli/releases/download/${VERSION}/cryptomator-cli-${VERSION}-linux-x64.zip" -o /tmp/cryptomator-cli-${VERSION}-linux-x64.zip && \
    unzip /tmp/cryptomator-cli-${VERSION}-linux-x64.zip -d /opt/ && \
    rm /tmp/cryptomator-cli-${VERSION}-linux-x64.zip && \
    ln -s /opt/cryptomator-cli/bin/cryptomator-cli /usr/local/bin/cryptomator

RUN curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

RUN useradd -u 1000 -m -s /bin/bash browser && \
    chown -R browser:browser /opt/cryptomator-cli/bin/cryptomator-cli

RUN mkdir -p /mnt/drive /srv && \
    chown browser:browser /mnt/drive /srv

USER browser

ENTRYPOINT ["filebrowser", \
            "--database", "/srv/filebrowser.db", \
            "-r", "/mnt/drive", \
            "--address", "0.0.0.0", \
            "--port", "8080"]