#cria a imagem de PHP com apache
FROM php:7.4-apache

RUN apt-get update \
&& apt upgrade -y \
&& apt-get install -y wget unzip cron vim nano 

RUN docker-php-ext-install -j$(nproc) mysqli

RUN set -eux; apt-get install -y libzip-dev

#descarrega e instala as librarias
RUN apt-get update \
  && apt-get install -f -y --no-install-recommends \
  rsync \
  netcat \
  libicu-dev \
  libz-dev \
  libpq-dev \
  libjpeg-dev \
  libfreetype6-dev \
  libmcrypt-dev \
  libbz2-dev \
  libjpeg62-turbo-dev \
  gnupg \
  libldap2-dev \
  libpng-dev \
  libxslt-dev \
  gettext \
  unixodbc-dev \
  uuid-dev \
  ghostscript \
  libaio1 \
  libgss3 \
  libicu63 \
  locales \
  sassc \
  libmagickwand-dev \
  libldap2-dev 

#instalação de extensões de php para que funcione corretamente
RUN docker-php-ext-configure soap --enable-soap \
&& docker-php-ext-configure bcmath --enable-bcmath \
&& docker-php-ext-configure pcntl --enable-pcntl \
&& docker-php-ext-configure zip \
&& docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
&& docker-php-ext-install -j$(nproc) zip opcache pgsql intl soap xmlrpc bcmath pcntl sockets ldap

RUN docker-php-ext-configure gd \
    --with-freetype=/usr/include/ \
    --with-jpeg=/usr/include/ \
    --enable-gd

RUN docker-php-ext-install -j$(nproc) gd

RUN pecl install igbinary uuid xmlrpc-beta imagick \
&& docker-php-ext-enable igbinary uuid xmlrpc imagick

RUN apt-get autopurge -y \
    && apt-get autoremove -y \
    && apt-get autoclean \ 
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* \
    && docker-php-source delete

# Especifica configurações do PHP necessárias para o Moodle
# php.ini
RUN set -ex \
    && { \
        echo 'log_errors = on'; \
        echo 'display_errors = off'; \
        echo 'always_populate_raw_post_data = -1'; \
        echo 'cgi.fix_pathinfo = 1'; \
        echo 'session.auto_start = 0'; \
        echo 'upload_max_filesize = 100M'; \
        echo 'post_max_size = 150M'; \
        echo 'max_execution_time = 1800'; \
        echo '[opcache]'; \
        echo 'opcache.enable = 1'; \
        echo 'opcache.memory_consumption = 128'; \
        echo 'opcache.max_accelerated_files = 8000'; \
        echo 'opcache.revalidate_freq = 60'; \
        echo 'opcache.use_cwd = 1'; \
        echo 'opcache.validate_timestamps = 1'; \
        echo 'opcache.save_comments = 1'; \
        echo 'opcache.enable_file_override = 0'; \ 
    } | tee /usr/local/etc/php/conf.d/php.ini

WORKDIR /var/www/html

#decarrega o código do moodle e descomprime
RUN wget https://download.moodle.org/download.php/direct/stable311/moodle-latest-311.tgz \
&& tar -zxvf moodle-latest-311.tgz \
&& rm -R moodle-latest-311.tgz \
&& chmod 0755 /var/www/html -R

#Dar permissões de usuário a pasta
RUN chown www-data.www-data /var/www/html -R

# Cria o diretório de arquivos do Moodle e dá permissões
RUN mkdir /var/www/moodledata && \ 
chmod 0770 /var/www/moodledata -R

#Dá permissões de usuario a pasta moodledata
RUN chown www-data /var/www/moodledata -R

#habilita o CRON
RUN echo "*/1 * * * * root php -q -f /var/www/html/moodle/admin/cli/cron.php > /var/log/moodle_cron.log" >> /etc/crontab

EXPOSE 80
