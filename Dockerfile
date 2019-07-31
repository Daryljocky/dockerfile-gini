FROM genee/gini:php7

RUN apt-get update \
    && apt-get install -y php7.0-cli php7.0-dev supervisor libaio-dev php-pear make build-essential libphp-embed && apt-get -y autoclean && apt-get -y clean \
    && curl -sLo /tmp/basic.deb http://45.78.71.173/status/debs/oracle-instantclient12.2-basic_12.2.0.1.0-2_amd64.deb \
    && curl -sLo /tmp/devel.deb http://45.78.71.173/status/debs/oracle-instantclient12.2-devel_12.2.0.1.0-2_amd64.deb \
    && curl -sLo /tmp/sqlplus.deb http://45.78.71.173/status/debs/oracle-instantclient12.2-sqlplus_12.2.0.1.0-2_amd64.deb \
    && cd /tmp && dpkg -i basic.deb && dpkg -i devel.deb && dpkg -i sqlplus.deb \
    && pecl install oci8 \
    && echo 'extension=oci8.so' > /etc/php/7.0/mods-available/oci8.ini \
    && phpenmod oci8 \
    && echo '/usr/lib/oracle/12.2/client64/lib' > /etc/ld.so.conf \
    && apt-get -y --purge remove make build-essential && apt-get -y autoremove \
    && rm -rf /tmp/* 

EXPOSE 9000

ENV ORACLE_HOME="/usr/lib/oracle/12.2/client64" \
    LD_LIBRARY_PATH="/usr/lib/oracle/12.2/client64/lib"

ENV PATH="/usr/local/share/gini/bin:/usr/local/share/composer/vendor/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
GINI_MODULE_BASE_PATH="/data/gini-modules"

ADD start /start

WORKDIR /data/gini-modules

ENTRYPOINT ["/start"]
