FROM ubuntu:latest

RUN apt-get update \
  && apt-get -y upgrade \
  # Install apache, PHP, and supplimentary programs. curl and lynx-cur are for debugging the container.
  && DEBIAN_FRONTEND=noninteractive apt-get -y install apache2 libapache2-mod-php5 php5-mysql php5-gd php-pear php-apc php5-curl curl lynx-cur \
  # Enable apache mods.
  && a2enmod php5 \
  && a2enmod rewrite \
  # Update the PHP.ini file, enable <? ?> tags and quieten logging.
  && sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php5/apache2/php.ini \
  && sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php5/apache2/php.ini \
  && echo 'ServerName localhost' >> /etc/apache2/apache2.conf \
  # Clean up apt
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

EXPOSE 80

ADD sharkys-adventure /var/www/html
ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf

CMD /usr/sbin/apache2ctl -D FOREGROUND
