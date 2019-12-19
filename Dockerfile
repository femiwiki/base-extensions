# Install composer, prestissimo, aria2, sudo and preload configuration file of
# aria2
#
# References:
#   https://getcomposer.org/
#   https://github.com/hirak/prestissimo
#   https://aria2.github.io/

FROM ruby:2.6

RUN apt-get update && apt-get install -y \
      # Required for composer
      php7.3-cli \
      php7.3-mbstring \
      # Required for prestissimo
      php7.3-curl \
      # Required for aws-sdk-php
      php7.3-simplexml \
      # Install other CLI utilities
      aria2 \
      sudo

# Install Composer
RUN EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)" &&\
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" &&\
    ACTUAL_SIGNATURE="$(php -r "echo hash_file('SHA384', 'composer-setup.php');")" &&\
    if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then \
      >&2 echo 'ERROR: Invalid installer signature' &&\
      rm composer-setup.php &&\
      exit 1; \
    fi &&\
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer --quiet

# Install prestissimo
RUN composer global require hirak/prestissimo

# Create a cache directory for composer
RUN sudo -u www-data mkdir -p /tmp/composer

# Install aria2.conf
COPY aria2.conf /root/.config/aria2/aria2.conf
