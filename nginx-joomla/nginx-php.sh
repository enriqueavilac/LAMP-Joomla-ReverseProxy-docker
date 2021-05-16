#!/bin/zsh

# update repositories
apt-get update

# install necessary packages
DEBIAN_FRONTEND=noninteractive apt-get --no-install-recommends install nginx \
  php7.4 php7.4-fpm php7.4-intl php7.4-mysqli php7.4-xdebug php7.4-xml php7.4-zip \
  curl ca-certificates -y

# remove nginx `default` index.html
rm /usr/share/nginx/html/index.html

# set joomla php.ini recommended settings
# sed -i "s/memory_limit = .*/memory_limit = 128M/" /etc/php/7.4/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 30M/" /etc/php/7.4/fpm/php.ini
sed -i "s/post_max_size = .*/post_max_size = 30M/" /etc/php/7.4/fpm/php.ini
sed -i "s/max_execution_time = .*/max_execution_time = 600/" /etc/php/7.4/fpm/php.ini

# set fpm adittional settings (if the database connection is too slow)
sed -i "s/;request_terminate_timeout = .*/request_terminate_timeout = 600/" /etc/php/7.4/fpm/pool.d/www.conf

# pass the environment variable to fpm joomla (by default fpm cleans every environment variable)
echo "env[JOOMLA_INSTALLATION_DISABLE_LOCALHOST_CHECK] = $JOOMLA_INSTALLATION_DISABLE_LOCALHOST_CHECK" >> /etc/php/7.4/fpm/pool.d/www.conf

# download joomla into our website folder, untar it
curl -sL https://downloads.joomla.org/es/cms/joomla3/3-9-26/Joomla_3-9-26-Stable-Full_Package.tar.gz | tar xvz -C /usr/share/nginx/html

# give www-data (nginx user) access to nginx root folder
chown -R www-data /usr/share/nginx/html

# create our configuration file with some content
echo "server {
    listen 80;
    listen [::]:80;

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log info;

    root /usr/share/nginx/html;
    index index.php index.html index.htm default.html default.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    add_header X-Content-Type-Options nosniff;

    location ~* /(images|cache|media|logs|tmp)/.*\.(php|pl|py|jsp|asp|sh|cgi)$ {
        return 403;
        error_page 403 /403_error.html;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_read_timeout 600;
        include /etc/nginx/fastcgi.conf;
    }

    location ~* \.(ico|pdf|flv)$ {
        expires 1y;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|swf|xml|txt)$ {
        expires 14d;
    }
}" > /etc/nginx/sites-available/default

# start php-fpm service
service php7.4-fpm start

# wait for 1 second
sleep 1

# start nginx service
nginx -g "daemon off;"
