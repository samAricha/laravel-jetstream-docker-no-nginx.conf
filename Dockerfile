FROM webdevops/php-nginx:8.2-alpine

# Install Laravel framework system requirements (https://laravel.com/docs/8.x/deployment#optimizing-configuration-loading)
RUN apk add oniguruma-dev postgresql-dev libxml2-dev nodejs npm
RUN docker-php-ext-install bcmath ctype pdo pdo_mysql bcmath opcache

#RUN docker-php-ext-install \
#        bcmath \
#        ctype
#        fileinfo \
#        nodejs \
#        npm \
#        mbstring \
#        pdo_mysql \
#        pdo_pgsql \
#        tokenizer \
#        xml

# Copy Composer binary from the Composer official Docker image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

ENV WEB_DOCUMENT_ROOT /app/public
ENV APP_ENV production
WORKDIR /app
COPY . .

RUN composer install --no-interaction --optimize-autoloader --no-dev
RUN npm install && npm run build
# Optimizing Configuration loading
RUN php artisan config:cache
# Optimizing Route loading
RUN php artisan route:cache
# Optimizing View loading
RUN php artisan view:cache

RUN chown -R application:application .
