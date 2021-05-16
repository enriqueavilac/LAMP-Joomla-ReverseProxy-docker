#!/bin/zsh

# update repositories
apt-get update

# install necessary packages
DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends install apache2 \
  php7.4 php7.4-bz2 php7.4-mbstring php7.4-xml php7.4-zip php7.4-mysqli \
  curl ca-certificates -y

# remove apache's default index.html file
rm /var/www/html/index.html

# creates a `tmp` folder
mkdir /var/www/html/tmp/

# give www-data (apache user) access to `tmp` folder
chown www-data /var/www/html/tmp/

# download phpMyAdmin, and untar it (only files, with --strip-components=1 the phpMyAdmin-5... folder won't be created)
curl -sL https://files.phpmyadmin.net/phpMyAdmin/5.1.0/phpMyAdmin-5.1.0-all-languages.tar.gz | tar xvz -C /var/www/html --strip-components=1

# clone the sample configuration
cp /var/www/html/config.sample.inc.php /var/www/html/config.inc.php

# You should generate a random string for this field (32 characters)
# Here I'm using `openssl rand -hex 16` but you can use any other generator.
sed -i "s/\$cfg\['blowfish_secret'\] = .*/\$cfg\['blowfish_secret'\] = '0ef409bb8aef25332c3430354d804dc4';/" /var/www/html/config.inc.php

# set database hostname
sed -i "s/\$cfg\['Servers'\]\[\$i\]\['host'\] = .*/\$cfg\['Servers'\]\[\$i\]\['host'\] = 'joomla_mysql_service';/" /var/www/html/config.inc.php

# run apache service
apachectl -D FOREGROUND