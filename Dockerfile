FROM alpine:edge
LABEL maintainer="workleast.com"

#Install Borg & SSH
RUN apk add --no-cache \
    tzdata \
    openssh \
    sshfs \
    borgbackup \
    supervisor
RUN adduser -D -u 1000 borg && \
    passwd -u borg && \
    mkdir -m 0700 /backups && \
    chown borg:borg /backups && \
    sed -i \
        -e 's/^#PasswordAuthentication yes$/PasswordAuthentication no/g' \
        -e 's/^PermitRootLogin without-password$/PermitRootLogin no/g' \
        /etc/ssh/sshd_config

RUN mkdir /home/borg/.ssh
RUN chown borg:borg /home/borg/.ssh

COPY built-in/supervisord.conf /etc/supervisord.conf
COPY built-in/service.sh /usr/local/bin/service.sh
COPY built-in/gen-sshkey.sh /usr/local/bin/gen-sshkey.sh
COPY built-in/fix-permission.sh /usr/local/bin/fix-permission.sh

RUN chmod +x /usr/local/bin/service.sh
RUN chmod +x /usr/local/bin/gen-sshkey.sh
RUN chmod +x /usr/local/bin/fix-permission.sh

EXPOSE 22

CMD ["/usr/bin/supervisord"]
