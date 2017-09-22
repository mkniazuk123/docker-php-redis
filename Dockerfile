FROM php:7.1.9-alpine

ENV BUILD_DEPS autoconf gcc cmake g++ make
ENV REDIS_VERSION 3.1.3

RUN apk update && apk add --no-cache --virtual .build-deps $BUILD_DEPS

# Install redis driver
RUN pecl install redis-$REDIS_VERSION \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis \
    && php -m | grep redis

# Install composer
WORKDIR /tmp
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

# Remove builddeps
RUN apk del .build-deps

ENTRYPOINT ["docker-php-entrypoint"]
CMD ["php", "-a"]
