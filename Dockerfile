FROM php:8.1-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    mariadb-client \
    libmariadb-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    gd \
    pdo_mysql \
    mysqli \
    zip \
    opcache

# Enable Apache mod_rewrite for Drupal
RUN a2enmod rewrite

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . .

# Fix file permissions
RUN chown -R www-data:www-data /var/www/html

# Install Composer dependencies
RUN composer install --no-interaction --optimize-autoloader

# Create necessary directories (settings.php is created by drush at runtime)
RUN mkdir -p sites/default/files private config/sync \
    && chmod -R 777 sites/default/files private \
    && chown -R www-data:www-data sites/default

# Copy initialization script
COPY docker-init.sh /var/www/html/docker-init.sh
RUN chmod +x /var/www/html/docker-init.sh && chown www-data:www-data /var/www/html/docker-init.sh

# Copy Apache configuration
RUN echo '<Directory /var/www/html>\n\
    Options Indexes FollowSymLinks\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>' > /etc/apache2/conf-available/drupal.conf \
    && a2enconf drupal

# Set Apache to listen on port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Start via initialization script with bash
CMD ["bash", "/var/www/html/docker-init.sh"]
