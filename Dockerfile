FROM alpine:3:20
LABEL maintainer="anorod"

#Install Borg & SSH
RUN apk add --no-cache \
    tzdata \
    openssh~=9.7 \
    sshfs \
    borgbackup~=1.2 \
    supervisor \ 
    net-tools && \
    rm -rf /var/cache/apk && \
    rm -rf /var/lib/app/lists*

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
COPY built-in/health-check.sh /usr/local/bin/healt-check.sh

RUN chmod +x /usr/local/bin/service.sh
RUN chmod +x /usr/local/bin/gen-sshkey.sh
RUN chmod +x /usr/local/bin/fix-permission.sh
RUN chmod +x /usr/local/bin/health-check.sh

EXPOSE 22

CMD ["/usr/bin/supervisord"]

HEALTHCHECK --interval=60s --timeout=30s --start-period=30s --retries=3 CMD [ "health-check.sh" ]