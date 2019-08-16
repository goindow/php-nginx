FROM php:7.1-fpm

MAINTAINER huangyabin <76788424@qq.com>

## 使用 www-data 权限，否则 runtime、web 等目录无足够权限写
RUN usermod -u 1000 www-data

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libjpeg-dev \
        libmcrypt-dev

RUN docker-php-ext-configure gd \
        --enable-gd-native-ttf \
        --with-jpeg-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-freetype-dir=/usr/include/freetype2/ && \
    docker-php-ext-install gd

RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install mcrypt
## 精确计算库
#RUN docker-php-ext-install bcmath

RUN apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN rm -rf /var/www/html

EXPOSE 9000
WORKDIR /var/www

CMD ["php-fpm"]
