FROM debian:12-slim
# Utility Packages
RUN apt-get update && \
    apt-get install -y \
        gnupg1 \
        apt-transport-https \
        ca-certificates \
        wget \
        git \
        wkhtmltopdf \
        bzip2
# Certificates installation and PHP packages repository adding
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ bookworm main" | \
      tee /etc/apt/sources.list.d/php.list && \
    cat /etc/apt/sources.list.d/php.list && \
    wget -O /etc/ssl/certs/curl-ca-bundle.crt https://curl.haxx.se/ca/cacert.pem && \
    chmod 777 /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/curl-ca-bundle.crt && \
    chown www-data:www-data /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/curl-ca-bundle.crt
# PHP Packages and required tools
RUN apt-get update && \
    apt-get install -y \
        nano \
        curl \
        tesseract-ocr \
        tesseract-ocr-eng \
        nginx \
        php7.3 \
        php7.3-curl \
        php7.3-soap \
        php7.3-json \
        php7.3-mbstring \
        php7.3-mysql \
        php7.3-simplexml \
        php7.3-odbc \
        php7.3-fpm \
        php7.3-mongodb \
        php7.3-gd \
        php7.3-xdebug
# PHP Project config
RUN openssl dhparam -out /etc/ssl/certs/ssl-cert-snakeoil.pem 2048 && \
    phpenmod curl json mbstring mysql odbc mongodb gd simplexml soap && \
    sed -i "s|;*clear_env\s*=\s*.*|clear_env = no|g" /etc/php/7.3/fpm/pool.d/www.conf && \
    rm -Rf /var/www/* && mkdir -p /run/php/ && \
    curl -sS https://getcomposer.org/installer | \
        php -- --install-dir=/usr/local/bin --filename=composer && \
    apt-get clean -qq && \
    apt-get autoremove -y -qq && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
# Install PhantomJs
RUN mkdir -p /root/phantomjs && \
    curl -kLS https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 -o /root/phantomjs/phantomjs-2.1.1-linux-x86_64.tar.bz2 && \
    tar xjf /root/phantomjs/phantomjs-2.1.1-linux-x86_64.tar.bz2 -C /root/phantomjs/ && \
    chmod +x /root/phantomjs/phantomjs-2.1.1-linux-x86_64/bin/phantomjs && \
    ln -s /root/phantomjs/phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs
# Copy the default nginx settings
COPY default /etc/nginx/sites-enabled/
# Copy the XDebug enabling config file
COPY 20-xdebug.ini /etc/php/7.3/fpm/conf.d/
# Copy execution binary for the entrypoint - Run Composer then start NGINX server
COPY startup.sh /run/
RUN chmod +x /run/startup.sh
# Forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log
WORKDIR /var/www
VOLUME ["/var/www", "/var/log/nginx", "/etc/nginx/conf.d/", "/etc/php/7.3/cli/conf.d"]
STOPSIGNAL SIGTERM
# Nginx service port
EXPOSE 80
CMD ["/bin/sh", "-c", "/run/startup.sh"]
ENTRYPOINT ["/bin/sh", "-c", "/run/startup.sh"]
