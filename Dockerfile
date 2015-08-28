# from https://www.drupal.org/requirements/php#drupalversions
FROM php:5.6-apache

MAINTAINER  Christian Ulbrich <christian.ulbrich@zalari.de>
ENV REFRESHED_AT 2015-08-27

RUN a2enmod rewrite

#no frontend, otherwise ssmtp install fails...
ENV DEBIAN_FRONTEND noninteractive

# install the PHP extensions we need + SSMTP
RUN apt-get update && apt-get install -y libpng12-dev libjpeg-dev libpq-dev ssmtp \
	&& rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-install gd mbstring pdo pdo_mysql pdo_pgsql

#setup ssmtp ENVs
ENV SMTP_MAILHOST localhost
ENV SMTP_PORT 25
ENV	SMTP_USER user
ENV SMTP_PASS pass
ENV SMTP_USE_TLS No
ENV SMTP_USE_TLS_CERTS No
ENV SMTP_FROM_OVERRIDE Yes
ENV SMTP_USE_STARTTLS No
ENV SMTP_ROOT root@localhost
ENV SMTP_HOSTNAME drupal.zz

#configure ssmtp by creating a new conf, generated from ENVs
RUN rm -f /etc/ssmtp/ssmtp.conf && \
	echo mailhub=${SMTP_MAILHOST}:${SMTP_PORT} >> /etc/ssmtp/ssmtp.conf && \
	echo root=${SMTP_ROOT} >> /etc/ssmtp/ssmtp.conf && \
	echo AuthUser=${SMTP_USER} >> /etc/ssmtp/ssmtp.conf && \
	echo AuthPass=${SMTP_PASS} >> /etc/ssmtp/ssmtp.conf && \
	echo UseTLS=${SMTP_USE_TLS} >> /etc/ssmtp/ssmtp.conf && \
	echo UseSTARTTLS=${SMTP_USE_STARTTLS} >> /etc/ssmtp/ssmtp.conf && \
	echo FromLineOverride=${SMTP_FROM_OVERRIDE} >> /etc/ssmtp/ssmtp.conf && \
	echo hostname=${SMTP_HOSTNAME} >> /etc/ssmtp/ssmtp.conf


WORKDIR /var/www/html

# https://www.drupal.org/node/3060/release
ENV DRUPAL_VERSION 7.39
ENV DRUPAL_MD5 6f42a7e9c7a1c2c4c9c2f20c81b8e79a

RUN curl -fSL "http://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz \
	&& echo "${DRUPAL_MD5} *drupal.tar.gz" | md5sum -c - \
	&& tar -xz --strip-components=1 -f drupal.tar.gz \
	&& rm drupal.tar.gz \
	&& chown -R www-data:www-data sites


#setup php.ini to allow for sending via ssmtp
#RUN echo [mail function]

#replace values in ssmtp.conf
#RUN sed -i 's/display_errors = Off/display_errors = On/' /etc/php5/apache2/php.ini
#RUN sed -i 's/display_errors = Off/display_errors = On/' /etc/php5/cli/php.ini

