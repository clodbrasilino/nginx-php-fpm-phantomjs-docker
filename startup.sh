#\!/bin/sh
 cd /var/www;
 composer --no-plugins --no-scripts install;
 php-fpm7.3;
 nginx -g 'daemon off;'
 