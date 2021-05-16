FROM ubuntu:20.04

LABEL maintainer="enriqueavilac"

ENV JOOMLA_INSTALLATION_DISABLE_LOCALHOST_CHECK=1

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive \
  apt-get --no-install-recommends install nginx \
  php7.4 php7.4-fpm php7.4-intl php7.4-mysqli php7.4-xdebug php7.4-xml php7.4-zip \
  curl ca-certificates -y && \
  rm /usr/share/nginx/html/index.html && \
  sed -i "s/upload_max_filesize = .*/upload_max_filesize = 30M/" /etc/php/7.4/fpm/php.ini && \
  sed -i "s/post_max_size = .*/post_max_size = 30M/" /etc/php/7.4/fpm/php.ini && \
  sed -i "s/max_execution_time = .*/max_execution_time = 600/" /etc/php/7.4/fpm/php.ini && \
  sed -i "s/;request_terminate_timeout = .*/request_terminate_timeout = 600/" /etc/php/7.4/fpm/pool.d/www.conf && \
  echo "env[JOOMLA_INSTALLATION_DISABLE_LOCALHOST_CHECK] = $JOOMLA_INSTALLATION_DISABLE_LOCALHOST_CHECK" >> /etc/php/7.4/fpm/pool.d/www.conf

RUN curl -sL https://downloads.joomla.org/es/cms/joomla3/3-9-26/Joomla_3-9-26-Stable-Full_Package.tar.gz | tar xvz -C /usr/share/nginx/html && \
  chown -R www-data /usr/share/nginx/html

COPY ./default.conf /etc/nginx/sites-available/default

EXPOSE 80

# This is a workaround only for Docker
CMD /usr/sbin/php-fpm7.4 -D && nginx -g "daemon off;"