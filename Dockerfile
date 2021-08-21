FROM php:7.4-fpm

ADD ./www.conf /usr/local/etc/php-fpm.d/www.conf

# Download script to install PHP extensions and dependencies
ADD https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/install-php-extensions /usr/local/bin/

RUN chmod uga+x /usr/local/bin/install-php-extensions && sync

RUN DEBIAN_FRONTEND=noninteractive apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -qq -y \
    curl \
    git \
    zip unzip \
    vim \
    && install-php-extensions \
    bcmath \
    bz2 \
    calendar \
    exif \
    gd \
    intl \
    ldap \
    memcached \
    mysqli \
    opcache \
    pdo_mysql \
    pdo_pgsql \
    pcntl \
    pgsql \
    redis \
    soap \
    xsl \
    zip

# Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "copy('https://composer.github.io/installer.sig', 'signature');" \
    && php -r "if (hash_file('SHA384', 'composer-setup.php') === trim(file_get_contents('signature'))) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

# Install GD
RUN apt-get install -y libfreetype-dev libjpeg8 libjpeg-turbo8-dev libwebp-dev libjpeg8-dev libpng-dev; \
    docker-php-ext-configure gd --with-freetype --with-webp --with-jpeg; \
    docker-php-ext-install -j$(nproc) gd

# Install Zip
RUN apt-get install -y libzip-dev && \
    docker-php-ext-configure zip; \
    docker-php-ext-install zip

# Install PhpRedis package:
RUN printf "\n" | pecl install -o -f redis \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis

# Install mariadb client
RUN apt-get install -y mariadb-client

COPY ./php.ini.dev /usr/local/etc/php/php.ini

RUN groupadd -g 1000 laravel 
RUN useradd -ms /bin/bash -G laravel -g 1000 laravel 
RUN mkdir -p /var/www/html \
    && mkdir -p /home/laravel/.composer \
    && chown laravel:laravel /var/www/html \
    && chown laravel:laravel /home/laravel/.composer

RUN mkdir /etc/supervisord.d
COPY .docker/laravel-horizon/php.ini /usr/local/etc/php/php.ini
COPY .docker/laravel-horizon/supervisord.d/* /etc/supervisord.d/
COPY .docker/laravel-horizon/supervisord.conf /etc/supervisord.conf

ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c",  "/etc/supervisord.conf"]

RUN php -v | head -n 1 | grep -q "PHP ${PHP_VERSION}."

WORKDIR /etc/supervisor/conf.d/
