FROM drupal:10-apache

# Arbeitsverzeichnis setzen
WORKDIR /var/www/html

# Composer bereits in Drupal-Image enthalten
# Zusätzliche Abhängigkeiten installieren
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    vim \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Erforderliche Drupal-Module installieren
RUN composer require drupal/admin_toolbar \
    drupal/pathauto \
    drupal/metatag \
    drupal/simple_sitemap \
    drupal/seckit \
    drupal/honeypot \
    drupal/memcache \
    drupal/cdn \
    drupal/webform \
    drush/drush

# Konfiguration von PHP für optimale Performance
RUN echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/drupal.ini \
    && echo "max_execution_time = 120" >> /usr/local/etc/php/conf.d/drupal.ini \
    && echo "upload_max_filesize = 64M" >> /usr/local/etc/php/conf.d/drupal.ini \
    && echo "post_max_size = 64M" >> /usr/local/etc/php/conf.d/drupal.ini \
    && echo "opcache.memory_consumption = 128" >> /usr/local/etc/php/conf.d/drupal.ini \
    && echo "opcache.interned_strings_buffer = 8" >> /usr/local/etc/php/conf.d/drupal.ini \
    && echo "opcache.max_accelerated_files = 4000" >> /usr/local/etc/php/conf.d/drupal.ini \
    && echo "opcache.revalidate_freq = 60" >> /usr/local/etc/php/conf.d/drupal.ini \
    && echo "opcache.fast_shutdown = 1" >> /usr/local/etc/php/conf.d/drupal.ini

# Startskript hinzufügen, das die Module aktiviert
COPY start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh

# Apache-Konfiguration anpassen für bessere Performance
RUN sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf \
    && echo "ServerTokens Prod" >> /etc/apache2/apache2.conf \
    && echo "ServerSignature Off" >> /etc/apache2/apache2.conf

# Module für Apache aktivieren
RUN a2enmod headers expires rewrite

# Container mit unserem Startskript starten
ENTRYPOINT ["/usr/local/bin/start.sh"]