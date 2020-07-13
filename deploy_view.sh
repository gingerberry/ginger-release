#!/usr/bin/env bash
set -euo pipefail

echo "====================="
echo "Deploying ginger-view"
echo "====================="

mkdir /var/www/html/ginger
pushd /var/www/html/ginger &> /dev/null || exit

sudo chmod -R a+w .

git clone https://github.com/gingerberry/ginger-view.git .

echo "An editor will be opened so you can edit your configuration..." && sleep 3

vim "js/config.js"

echo "Configuration edited successfully!"

popd &> /dev/null || exit

echo "Successfully deployed gingerberry view! :)"
