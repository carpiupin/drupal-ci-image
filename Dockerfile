# Build an image for a drupal enviroment with:
#	Apache-php: 7.2
#	Mysql and Postgresql extensions
#	Drush
#	Composer
#	Postgresql (client required for drush)
#	Mysql-client (required for drush)

# From docker4drupal image
FROM php:7.1-apache

# install the PHP extensions we need
RUN set -ex; \
	\
	if command -v a2enmod; then \
		a2enmod rewrite; \
	fi; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libjpeg-dev \
		libpng-dev \
		libpq-dev \
	; \
	\
	docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
	docker-php-ext-install -j "$(nproc)" \
		gd \
		opcache \
		pdo_mysql \
		pdo_pgsql \
		zip \
	; \
	\
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
		| awk '/=>/ { print $3 }' \
		| sort -u \
		| xargs -r dpkg-query -S \
		| cut -d: -f1 \
		| sort -u \
		| xargs -rt apt-mark manual; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*

# set recommended PHP.ini settings
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Dirs required to install postgresql throught build-essential
RUN mkdir /usr/share/man/man1/
RUN mkdir /usr/share/man/man7

# Instal utils and postgresql
RUN apt-get update && apt-get install -y \
	git \
	vim \
	wget \
	unzip \
	postgresql \
	mysql-client

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install drush
RUN wget -O drush.phar https://github.com/drush-ops/drush-launcher/releases/download/0.4.2/drush.phar && \
	chmod +x drush.phar && \
	mv drush.phar /usr/local/bin/drush

# Remove symlinks to devices and create log files to avoid errors starting apache2 with error.log symlink device in docker
RUN rm -rf /var/log/apache2/*
RUN cd /var/log/apache2/ && \
	touch access.log error.log other_vhosts_access.log && \
	chmod 755 access.log error.log other_vhosts_access.log

EXPOSE 80

WORKDIR /var/www/html