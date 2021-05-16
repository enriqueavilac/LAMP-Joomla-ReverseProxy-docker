FROM ubuntu:20.04

LABEL maintainer="enriqueavilac"

ENV JOOMLA_INSTALLATION_DISABLE_LOCALHOST_CHECK=1

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive \
  apt-get --no-install-recommends install apache2 \
  php7.4 php7.4-mysqli php7.4-xml php7.4-zip \
  curl ca-certificates -y && \
  rm /var/www/html/index.html && \
  sed -i "s/upload_max_filesize = .*/upload_max_filesize = 30M/" /etc/php/7.4/apache2/php.ini && \
  sed -i "s/post_max_size = .*/post_max_size = 30M/" /etc/php/7.4/apache2/php.ini

RUN curl -sL https://downloads.joomla.org/es/cms/joomla3/3-9-26/Joomla_3-9-26-Stable-Full_Package.tar.gz | tar xvz -C /var/www/html && \
  chown -R www-data /var/www/html

EXPOSE 80

CMD ["apachectl", "-D", "FOREGROUND"]