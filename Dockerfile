FROM php:7.1.9-alpine

ENV BUILD_DEPS autoconf gcc cmake g++ make
ENV REDIS_VERSION 3.1.3
ENV IGBINARY_VERSION 2.0.4

RUN apk update && apk add --no-cache --virtual .build-deps $BUILD_DEPS

# Install XDebug
RUN pecl install xdebug \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable xdebug \
    && php -m | grep xdebug

# Install igbinary
RUN pecl install igbinary-$IGBINARY_VERSION \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable igbinary \
    && php -m | grep igbinary

# Install redis driver
RUN mkdir -p /tmp/pear \
    && cd /tmp/pear \
    && pecl bundle redis-$REDIS_VERSION \
    && cd redis \
    && phpize . \
    && ./configure --enable-redis-igbinary \
    && make \
    && make install \
    && cd ~ \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis \
    && php -m | grep redis

# Check if redis see igbinary
RUN php -r 'echo Redis::SERIALIZER_IGBINARY;'

# Install composer
WORKDIR /tmp
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

# Remove builddeps
RUN apk del .build-deps

ENTRYPOINT ["docker-php-entrypoint"]
CMD ["php", "-a"]
