FROM serversideup/php:8.2-fpm-nginx

# Install PHP Imagemagick using regular Ubuntu commands
RUN apt-get update
RUN apt-get install -y libaio1 libaio-dev build-essential php-pear php8.2-dev
RUN apt-get install -y php8.2-pgsql php8.2-gd
#RUN apt-get install -y build-essential zip libzip-dev libpq-dev postgresql postgresql-client

# Download oracle packages and install OCI8
ADD https://download.oracle.com/otn_software/linux/instantclient/1920000/instantclient-basic-linux.x64-19.20.0.0.0dbru.zip /tmp/
ADD https://download.oracle.com/otn_software/linux/instantclient/1920000/instantclient-sdk-linux.x64-19.20.0.0.0dbru.zip /tmp/
RUN mkdir /opt/oracle
RUN unzip /tmp/instantclient-basic-linux.x64-19.20.0.0.0dbru.zip -d /opt/oracle/
RUN unzip /tmp/instantclient-sdk-linux.x64-19.20.0.0.0dbru.zip -d /opt/oracle/

RUN ln -s /opt/oracle/instantclient_19_20/sdk/include/*.h /usr/local/include/
RUN ln -s /opt/oracle/instantclient_19_20/*.dylib /usr/local/lib/
RUN ln -s /opt/oracle/instantclient_19_20/*.dylib.19.1 /usr/local/lib/
#RUN ln -s /usr/local/lib/libclntsh.dylib.19.1 /usr/local/lib/libclntsh.dylib

RUN echo /opt/oracle/instantclient_19_20 > /etc/ld.so.conf.d/oracle-instantclient.conf
RUN ldconfig

#ENV LD_LIBRARY_PATH /opt/oracle/instantclient_19_20

# install oracle php extension
RUN echo 'instantclient,/opt/oracle/instantclient_19_20' | pecl install oci8
RUN echo "extension=oci8.so" > /etc/php/8.2/fpm/conf.d/oci8.ini

# clean apt cache
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*
