FROM wordpress:php7.1

# Install apt-get packages
RUN apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y git subversion mysql-client\
    && rm -rf /var/lib/apt/lists/*

# Install phpunit
WORKDIR /tmp
RUN docker-php-ext-install pcntl
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/bin --filename=composer \
    && php -r "unlink('composer-setup.php');" \
    && composer require "phpunit/phpunit:~5.7" --prefer-source --no-interaction \
    && composer require "phpunit/php-invoker" --prefer-source --no-interaction \
    && ln -s /tmp/vendor/bin/phpunit /usr/local/bin/phpunit \
    && sed -i 's/nn and/nn, Julien Breux (Docker) and/g' /tmp/vendor/phpunit/phpunit/src/Runner/Version.php;
WORKDIR /var/www/html

# Install xdebug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && rm -rf /tmp/pear/
# Configure xdebug
RUN { \
      echo ''; \
      echo 'xdebug.remote_enable=1'; \
      echo 'xdebug.remote_autostart=1'; \
      echo 'xdebug.remote_host="docker.for.mac.localhost"'; \
      echo 'xdebug.remote_port="9000"'; \
      echo 'xdebug.remote_log="/var/log/xdebug.log"'; \
    } >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
