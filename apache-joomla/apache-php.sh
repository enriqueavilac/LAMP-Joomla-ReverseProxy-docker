#!/bin/zsh

# update repositories
apt-get update

# install necessary packages
DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends install apache2 \
  php7.4 php7.4-mysqli php7.4-xml php7.4-zip \
  curl ca-certificates -y

# remove apache's default index.html file
rm /var/www/html/index.html

# set joomla php.ini recommended settings
# sed -i "s/memory_limit = .*/memory_limit = 128M/" /etc/php/7.4/apache2/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 30M/" /etc/php/7.4/apache2/php.ini
sed -i "s/post_max_size = .*/post_max_size = 30M/" /etc/php/7.4/apache2/php.ini
# sed -i "s/max_execution_time = .*/max_execution_time = 3000/" /etc/php/7.4/apache2/php.ini

# download joomla into our website folder, untar it
curl -sL https://downloads.joomla.org/es/cms/joomla3/3-9-26/Joomla_3-9-26-Stable-Full_Package.tar.gz | tar xvz -C /var/www/html

# Try to not set this permission (you'll notice how the FTP tab appears)
chown -R www-data /var/www/html/

# run apache service
apachectl -D FOREGROUND
