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

COPY ./php.ini.dev /usr/local/etc/php/php.ini

RUN groupadd -g 1000 laravel 
RUN useradd -ms /bin/bash -G laravel -g 1000 laravel 
RUN mkdir -p /var/www/html \
    && mkdir -p /home/laravel/.composer \
    && chown laravel:laravel /var/www/html \
    && chown laravel:laravel /home/laravel/.composer

WORKDIR /var/www/html
