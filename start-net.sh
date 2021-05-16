#!/bin/zsh
##################################
#           Created by:          #
#          Enrique Avila         #
##################################

# Creating the network
docker network create joomla_net

# Creating instances

# This starts a mysql container for information store.
docker container run --rm --name joomla_mysql --network joomla_net --network-alias joomla_mysql_service -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=joomla mysql:8.0.17 

# This starts an ubuntu container for nginx-joomla server
docker container run -it --rm --name joomla_db_admin --network joomla_net --network-alias joomla_db_admin_service --expose 80 ubuntu bash

# This starts an ubuntu container for nginx-joomla server
docker container run -it --rm --name joomla_nginx --network joomla_net --network-alias joomla_nginx_service --expose 80 -e JOOMLA_INSTALLATION_DISABLE_LOCALHOST_CHECK=1 ubuntu bash

# this starts an ubuntu container for apache-joomla server
docker container run -it --rm --name joomla_apache --network joomla_net --network-alias joomla_apache_service --expose 80 -e JOOMLA_INSTALLATION_DISABLE_LOCALHOST_CHECK=1 ubuntu bash

# Creating reverse-proxy instance

docker container run --rm --name joomla_reverse_proxy --network joomla_net --network-alias joomla_reverse_proxy_service -p 80:80 joomla_reverse_proxy_image