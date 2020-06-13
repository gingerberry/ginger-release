#!/usr/bin/env bash

# Install php and apache2 server.
apt-get update
apt-get install apache2 <<< "Y"
apt-get install php libapache2-mod-php <<< "Y"

# Configure php and apache2.
a2enmod rewrite
a2enmod headers

TMP_FILE="$(mktemp tmp.XXXXXXX)"
sed -E 's/(AllowOverride) None/\1 All/g' < /etc/apache2/apache2.conf > "$TMP_FILE"
cat "$TMP_FILE" > /etc/apache2/apache2.conf

sudo apt-get install php7.2-mysql
sudo apt install php-simplexml

systemctl restart apache2

pushd /var/www/html &> /dev/null || exit

git clone https://github.com/gingerberry/ginger-bottom.git  .
sudo apt install php-simplexml
php composer.phar update

popd &> /dev/null || exit
