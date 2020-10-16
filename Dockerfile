FROM nginx:1.17.4-alpine

# Install system packages for PHP extensions recommended for Yii 2.0 Framework
RUN apk add --no-cache php7 php7-dev php7-pear php7-fpm php7-mysqli php7-pdo_mysql php7-json php7-openssl php7-curl \
    php7-zlib php7-xml php7-simplexml php7-phar php7-intl php7-dom php7-xmlreader php7-xmlwriter  php7-ctype php7-session \
    php7-mbstring php7-gd php-zip supervisor  libxml2-dev php7-tokenizer
RUN apk add autoconf gcc g++ make

# Install PHP extensions required for Yii 2.0 Framework
ARG X_LEGACY_GD_LIB=0
RUN docker-php-ext-configure gd \
                --with-freetype=/usr/include/ \
                --with-jpeg=/usr/include/; \
    docker-php-ext-configure bcmath && \
    docker-php-ext-install \
        soap \
        zip \
        curl \
        bcmath \
        exif \
        gd \
        iconv \
        intl \
        mbstring \
        opcache \
        pdo_mysql \
        pdo_pgsql

# Install PECL extensions
# see http://stackoverflow.com/a/8154466/291573) for usage of `printf`
RUN printf "\n" | pecl install \
        imagick && \
    docker-php-ext-enable \
        imagick
# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
# Environment settings
ENV COMPOSER_ALLOW_SUPERUSER=1 \
    PHP_USER_ID=33 \
    PATH=/app:/app/vendor/bin:/root/.composer/vendor/bin:$PATH \
    VERSION_PRESTISSIMO_PLUGIN=^0.3.7

# Add configuration files
COPY image-files/ /
COPY ./supervisor.conf /etc/supervisor/conf.d/supervisord.conf

# Add GITHUB_API_TOKEN support for composer
RUN chmod 700 \
        /usr/local/bin/docker-php-entrypoint \
        /usr/local/bin/composer
# Install composer plugins
RUN composer global require --optimize-autoloader \
        "hirak/prestissimo:${VERSION_PRESTISSIMO_PLUGIN}" && \
    composer global dumpautoload --optimize && \
    composer clear-cache

# Install Yii framework bash autocompletion
RUN curl -L https://raw.githubusercontent.com/yiisoft/yii2/master/contrib/completion/bash/yii \
        -o /etc/bash_completion.d/yii

# Application environment
COPY default /etc/nginx/sites-available/default
COPY  . /var/www/html/app

WORKDIR /var/www/html/app   

#RUN apt-get update && \
     # apt-get -y install sudo

#RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo

#USER docker
#CMD /bin/bash
#RUN useradd -ms /bin/bash admin
#RUN chown -R admin:admin /var/www/html/app
#RUN chmod -R 777 /var/www/html/app

#RUN chmod -R 777 /var/www/html/app  

#update composer
RUN  composer update
#USER admin
RUN chmod a+rwx -R /var/www/html/app


             

