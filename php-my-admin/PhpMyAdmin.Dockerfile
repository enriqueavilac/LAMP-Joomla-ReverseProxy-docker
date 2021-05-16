FROM ubuntu:20.04

LABEL maintainer="enriqueavilac"

ENV PHP_BLOWFISH_SECRET=yoursecret32charstring \
  PHP_DB_HOST=localhost

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive \
  apt-get --no-install-recommends install apache2 \
  php7.4 php7.4-bz2 php7.4-mbstring php7.4-xml php7.4-zip php7.4-mysqli \
  curl ca-certificates -y && \
  rm /var/www/html/index.html && \
  mkdir /var/www/html/tmp && \
  chown www-data /var/www/html/tmp

RUN curl -sL https://files.phpmyadmin.net/phpMyAdmin/5.1.0/phpMyAdmin-5.1.0-all-languages.tar.gz | tar xvz -C /var/www/html --strip-components=1 && \
  cp /var/www/html/config.sample.inc.php /var/www/html/config.inc.php && \
  sed -i "s/\$cfg\['blowfish_secret'\] = .*/\$cfg\['blowfish_secret'\] = getenv('PHP_BLOWFISH_SECRET');/" /var/www/html/config.inc.php && \
  sed -i "s/\$cfg\['Servers'\]\[\$i\]\['host'\] = .*/\$cfg\['Servers'\]\[\$i\]\['host'\] = getenv('PHP_DB_HOST');/" /var/www/html/config.inc.php

EXPOSE 80

CMD ["apachectl", "-D", "FOREGROUND"]
