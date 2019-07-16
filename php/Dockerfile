FROM php:7.1-fpm

MAINTAINER huangyabin <76788424@qq.com>

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libfreetype6-dev \
		libjpeg62-turbo-dev \
		libpng-dev \
        libjpeg-dev

RUN docker-php-ext-install pdo_mysql

RUN docker-php-ext-configure gd \
        --enable-gd-native-ttf \
        --with-jpeg-dir=/usr/lib \
        --with-freetype-dir=/usr/include/freetype2 && \
    docker-php-ext-install gd

RUN apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 9000
WORKDIR /var/www

CMD ["php-fpm"]
