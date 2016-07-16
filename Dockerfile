FROM php:7-fpm-alpine

# Install dependencies
RUN apk add --no-cache bash curl libmemcached-dev autoconf build-base zlib-dev libmcrypt-dev

RUN curl -fsSL 'https://github.com/websupport-sk/pecl-memcache/archive/NON_BLOCKING_IO_php7.zip' -o memcache.zip \
    && unzip memcache.zip \
    && rm memcache.zip \
    && ( \
        cd pecl-memcache-NON_BLOCKING_IO_php7 \
        && phpize \
        && ./configure --enable-memcache \
        && make -j$(nproc) \
        && make install \
    ) \
    && rm -r pecl-memcache-NON_BLOCKING_IO_php7

RUN docker-php-ext-install mysqli mcrypt && \
    docker-php-ext-enable mysqli mcrypt memcache

# https://github.com/Yelp/dumb-init
RUN curl -fsSL 'https://github.com/Yelp/dumb-init/releases/download/v1.1.1/dumb-init_1.1.1_amd64' -o /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init

EXPOSE 9000

# Clean APK cache
RUN rm -rf /var/cache/apk/*
RUN apk del autoconf build-base

# Clear out old default site content
RUN rm -rf /var/www/html/*

RUN mkdir -p /var/www/html/web
RUN mkdir -p /var/www/html/include


CMD ["dumb-init", "php-fpm"]