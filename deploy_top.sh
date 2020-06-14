#!/usr/bin/env bash
set -euo pipefail

TOMCAT_PORT="$1"

replaceInFile() {
    REPLACE_STRING="${1}"
    FILE="${2}"
    
    TMP_FILE="$(mktemp tmp.XXXXXXX)"
    sed -E "s/${REPLACE_STRING}/g" < "$FILE" > "$TMP_FILE"
    cat "$TMP_FILE" > "$FILE"
    rm "$TMP_FILE"
}

pushd "$HOME" &> /dev/null

echo "================="
echo "Installing Tomcat"
echo "================="

# check if dir present
if [ ! -d  "apache-tomcat-8.5.56" ]; then
    wget http://apache.cbox.biz/tomcat/tomcat-8/v8.5.56/bin/apache-tomcat-8.5.56.tar.gz
    tar -zvxf apache-tomcat-8.5.56.tar.gz
fi

pushd apache-tomcat-8.5.56 &> /dev/null

chmod +x bin/startup.sh
chmod +x bin/shutdown.sh

mv assets/tomcat-users.xml conf/tomcat-users.xml
replaceInFile "8080/${TOMCAT_PORT}" "conf/server.xml"

./bin/startup.sh

popd &> /dev/null


echo "================"
echo "Installing Maven"
echo "================"
apt install maven <<< "Y"

echo "=============="
echo "Installing App"
echo "=============="
rm -rf ginger-top
git clone https://github.com/gingerberry/ginger-top.git
mvn clean tomcat7:deploy

popd &> /dev/null
