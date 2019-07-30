FROM alpine:3.7
MAINTAINER iamfat@gmail.com

ENV TERM="xterm-color" \
    MAIL_HOST="172.17.0.1" \
    MAIL_FROM="sender@gini" \
    GINI_ENV="production" \
    COMPOSER_PROCESS_TIMEOUT=40000 \
    COMPOSER_HOME="/usr/local/share/composer"

ADD pei /usr/local/share/pei
ADD pei.bash /usr/local/bin/pei

RUN apk update \
    && apk add bash curl gettext php7 php7-fpm \
      && sed -i 's/^listen\s*=.*$/listen = 0.0.0.0:9000/' /etc/php7/php-fpm.d/www.conf \
      && sed -i 's/^\;error_log\s*=.*$/error_log = \/dev\/stderr/' /etc/php7/php-fpm.conf \
      && sed -i 's/^\;error_log\s*=\s*syslog\s*$/error_log = \/dev\/stderr/' /etc/php7/php.ini \
      && ln -sf /usr/sbin/php-fpm7 /usr/sbin/php-fpm \
      && ln -sf /usr/bin/php7 /usr/bin/php \
    && pei session intl gd mcrypt pdo pdo_mysql pdo_sqlite curl \
      json phar openssl bcmath dom ctype iconv zip xml zlib mbstring \
      ldap gettext posix pcntl simplexml tokenizer xmlwriter fileinfo yaml \
      zmq redis friso \
    && apk add nodejs nodejs-npm && npm install -g less less-plugin-clean-css uglify-js \
    && apk add msmtp && ln -sf /usr/bin/msmtp /usr/sbin/sendmail \
    && apk add git \
    && mkdir -p /usr/local/bin && (curl -sL https://getcomposer.org/installer | php) \
      && mv composer.phar /usr/local/bin/composer \
    && mkdir -p /data/gini-modules && git clone https://github.com/iamfat/gini /usr/local/share/gini \
        && cd /usr/local/share/gini && bin/gini composer init -f \
        && /usr/local/bin/composer install --no-dev \
        && bin/gini cache \
    && apk add add rpm libaio && curl -sLo /tmp/oracle.rpm http://files.docker.genee.in/oracle-instantclient12.2-basic-12.2.0.1.0-1.x86_64.rpm \
    && curl -sLo /tmp/oracle-devel.rpm http://files.docker.genee.in/oracle-instantclient12.2-devel-12.2.0.1.0-1.x86_64.rpm \
    && rpm -i --nodeps /tmp/oracle.rpm /tmp/oracle-devel.rpm \
    && [ ! -d /tmp/oci8-2.1.8 ] && curl -sL https://pecl.php.net/get/oci8-2.1.8.tgz | tar -zxf - -C /tmp \
    && cd /tmp/oci8-2.1.8 && phpize7 && ./configure --with-php-config=/usr/bin/php-config7 \
    && make && make install \
    && rm -rf /var/cache/apk/*

ADD msmtprc /etc/msmtprc

EXPOSE 9000

ENV PATH="/data/gini-modules/gini/bin:/usr/local/share/composer/vendor/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
GINI_MODULE_BASE_PATH="/data/gini-modules"

ADD start /start
WORKDIR /data/gini-modules
CMD ["/start"]
