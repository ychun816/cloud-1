FROM php:8.1-fpm-alpine

# Install build dependencies and PHP extensions
RUN apk add --no-cache mariadb-client \
    && docker-php-ext-install mysqli pdo pdo_mysql

# Install dependencies for Adminer
RUN apk add --no-cache wget \
    && mkdir -p /var/www/html

# Download Adminer (single PHP file)
RUN wget -O /var/www/html/index.php "https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php"

# Set ownership
RUN chown -R www-data:www-data /var/www/html

WORKDIR /var/www/html

EXPOSE 9000

CMD ["php-fpm"]
