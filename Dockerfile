FROM php:7.4-apache

# Install system packages for PHP extensions recommended for Yii 2.0 Framework
RUN apt-get update && \
    apt-get -y install \
        gnupg2 && \
    apt-key update && \
    apt-get update && \
    apt-get -y install \
            g++ \
            git \
            curl \
            imagemagick \
            libcurl3-dev \
            libicu-dev \
            libfreetype6-dev \
            libjpeg-dev \
            libjpeg62-turbo-dev \
            libonig-dev \
            libmagickwand-dev \
            libpq-dev \
            libpng-dev \
            libxml2-dev \
            libzip-dev \
            zlib1g-dev \
            default-mysql-client \
            openssh-client \
            nano \
            unzip \
            libcurl4-openssl-dev \
            libssl-dev \
        --no-install-recommends && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

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

# Environment settings
ENV COMPOSER_ALLOW_SUPERUSER=1 \
    PHP_USER_ID=33 \
    PATH=/app:/app/vendor/bin:/root/.composer/vendor/bin:$PATH \
    VERSION_PRESTISSIMO_PLUGIN=^0.3.7

# Add configuration files
COPY image-files/ /

# Add GITHUB_API_TOKEN support for composer
RUN chmod 700 \
        /usr/local/bin/docker-php-entrypoint \
        /usr/local/bin/composer

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- \
        --filename=composer.phar \
        --install-dir=/usr/local/bin && \
    composer clear-cache

# Install composer plugins
RUN composer global require --optimize-autoloader \
        "hirak/prestissimo:${VERSION_PRESTISSIMO_PLUGIN}" && \
    composer global dumpautoload --optimize && \
    composer clear-cache

# Install Yii framework bash autocompletion
RUN curl -L https://raw.githubusercontent.com/yiisoft/yii2/master/contrib/completion/bash/yii \
        -o /etc/bash_completion.d/yii

# Application environment
COPY vhost.conf /etc/apache2/sites-available/000-default.conf
COPY  . /var/www/html/app

#RUN rm -R /var/www/html/app/web/assets
#RUN mkdir -p /var/www/html/app/web/assets
#RUN chmod -R 777 /var/www/html/app/web/assets
#RUN chown -R www-data:www-data /var/www/html/app/web/assets

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