FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y --no-install-recommends apache2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN a2dismod status autoindex -f && \
    a2enmod headers ssl rewrite proxy proxy_http

RUN groupadd -g 1001 apache-grp && \
    useradd -u 1001 -g apache-grp -s /sbin/nologin apache-usr

COPY httpd.conf    /etc/apache2/apache2.conf
COPY security.conf /etc/apache2/conf-enabled/security.conf

RUN mkdir -p /run/apache2 && \
    chown -R apache-usr:apache-grp /var/www /var/log/apache2 /run/apache2 /etc/apache2 && \
    chmod 750 /var/log/apache2

USER apache-usr:apache-grp
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s \
    CMD curl -f http://127.0.0.1:8080/ || exit 1

CMD ["apache2ctl", "-D", "FOREGROUND"]