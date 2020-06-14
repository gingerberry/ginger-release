#!/usr/bin/env bash
set -euo pipefail

SYSTEM_HOSTNAME="${1}"
BOTTOM_PORT="${2}"
TOP_PORT="${3}"

replaceInFile() {
    REPLACE_STRING="${1}"
    FILE="${2}"

    TMP_FILE="$(mktemp tmp.XXXXXXX)"
    sed -E "s/${REPLACE_STRING}/g" < "$FILE" > "$TMP_FILE"
    cat "$TMP_FILE" > "$FILE"
    rm "$TMP_FILE"
}

# Install php and apache2 server.
echo "=============="
echo "Installing php"
echo "=============="
apt-get update
apt-get install apache2 <<< "Y"
apt-get install php libapache2-mod-php <<< "Y"

# Configure php and apache2.
echo "========================="
echo "Configuring prerequisites"
echo "========================="

a2enmod rewrite
a2enmod headers

TMP_FILE="$(mktemp tmp.XXXXXXX)"
sed -E 's/(AllowOverride) None/\1 All/g' < /etc/apache2/apache2.conf > "$TMP_FILE"
cat "$TMP_FILE" > /etc/apache2/apache2.conf
rm "$TMP_FILE"

echo "AddDefaultCharset utf-8" >> /etc/apache2/apache2.conf

sudo apt-get install php7.2-mysql
sudo apt install php-simplexml

systemctl restart apache2

echo "================="
echo "Installing ffmpeg"
echo "================="

sudo apt-get install ffmpeg

echo "======================="
echo "Deploying ginger-bottom"
echo "======================="

find /var/www/html -xdev -mindepth 1 -printf "%d\t%y\t%p\0" | sort -z -r -n | cut -z -f3- | xargs -0 -r -- rm -d --

mkdir /var/www/html/gingerberry
pushd /var/www/html/gingerberry &> /dev/null || exit

git clone https://github.com/gingerberry/ginger-bottom.git  .
sudo apt install php-simplexml
php composer.phar update

popd &> /dev/null || exit

echo "=================="
echo "Running smoke test"
echo "=================="
LIVENESS_PROBE="$(curl -I --location --request OPTIONS 'http://localhost:80/gingerberry/' -w "%{http_code}" -o /dev/null -s)"

if [ "$LIVENESS_PROBE" != "200" ]; then
        echo "Health check failed. Expected 200 got $LIVENESS_PROBE"
       exit 1
fi

echo "====================="
echo "Deploying ginger-view"
echo "====================="

mkdir /var/www/html/ginger
pushd /var/www/html/ginger &> /dev/null || exit

git clone https://github.com/gingerberry/ginger-view.git .

replaceInFile "localhost/${SYSTEM_HOSTNAME}" "js/config.js"
replaceInFile "8000/${BOTTOM_PORT}" "js/config.js"
replaceInFile "9090/${TOP_PORT}" "js/config.js"

popd &> /dev/null || exit

echo "Successfully deployed gingerberry apache artifacts! :)"