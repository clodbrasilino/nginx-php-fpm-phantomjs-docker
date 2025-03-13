# Docker images for common NGINX + PHP7 + PhantomJS Services

Docker image for working with nginx, php7-fpm, php mongo extensions, phantomJS and tesseract OCR.

## How to run
``` docker run -d clodbrasilino/hv-stack:latest ```

## How to build
``` docker build -t <your_tag> -f Dockerfile . ```

## Software installed:
- Nginx
- PHP 7.3 (FPM)
- composer (from php)
- php-mongodb module
- php-mysql module
- php-xdebug module (be sure to disable the debugger in a php config file if not needed)
- tesseract-ocr
- phantomjs

# How to disable the XDebug module

The XDebug module is activated by default in the dockerhub image (with improved `var_dump()` function and step-debugging support). To disable it, comment the `COPY 20-xdebug.ini /etc/php/7.3/fpm/conf.d/` command in the (Dockerfile)[./Dockerfile].

## Volumes

- /var/www
- /var/log/nginx
- /etc/nginx/
- /etc/nginx/conf.d/
- /etc/php/7.3/fpm/conf.d/

## Exposed Ports

- `80`