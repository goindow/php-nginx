FROM php:7.4.33-fpm

MAINTAINER huangyabin <76788424@qq.com>

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libjpeg-dev \
        pkg-config \
        libmcrypt-dev \
        libcurl4-openssl-dev \
        libssl-dev

RUN docker-php-ext-configure gd \
        --enable-gd-native-ttf \
        --with-jpeg-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-freetype-dir=/usr/include/freetype2/ && \
    docker-php-ext-install gd && \
    docker-php-ext-install opcache && \
    docker-php-ext-enable opcache

## 因为老项目兼容性问题无法预估，这里没有使用升级到 php-fpm7.1+ 的方式。新项目推荐升级 php-fpm + 最新的 mongodb 扩展
## mongodb 扩展从 1.12.0 开始放弃支持 php7.1，这里指定 1.11.1 版本
#RUN pecl install mongodb && \
RUN pecl install https://pecl.php.net/get/mongodb-1.11.1.tgz && \
    docker-php-ext-enable mongodb

RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install mcrypt
RUN docker-php-ext-install zip
## 精确计算库
#RUN docker-php-ext-install bcmath

RUN apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN rm -rf /var/www/html

WORKDIR /var/www

EXPOSE 9000

CMD ["php-fpm"]
