#! /bin/bash

if [[ -z $1 || -z $2 || "$1" == "$2" ]]; then
    echo "Usage: ${0} old_version new_version"
    exit 1
fi

echo "Updating Session-Desktop Void from version ${1} to version ${2}..."

git fetch -q
git pull -q
git checkout -q origin/master -b "v${2/+/-}" || { echo "Unable to create branch ${2}"; exit 2; }

sed -i "s/version=${1/-/+}/version=${2/-/+}/" void-packages/srcpkgs/session-desktop/template

wget -q https://github.com/session-foundation/session-desktop/archive/refs/tags/v${1/+/-}.tar.gz -P /tmp/ > /dev/null || { echo "Unable to download Session-Desktop v${1/+/-}.tar.gz"; exit 3; }
OLD_SESSION_HASH=`sha256sum /tmp/v${1/+/-}.tar.gz | awk '{ print $1 }'`
rm /tmp/v${1/+/-}.tar.gz

wget -q https://github.com/session-foundation/session-desktop/archive/refs/tags/v${2/+/-}.tar.gz -P /tmp/ > /dev/null || { echo "Unable to download Session-Desktop v${2/+/-}.tar.gz"; exit 4; }
SESSION_HASH=`sha256sum /tmp/v${2/+/-}.tar.gz | awk '{ print $1 }'`
rm /tmp/v${2/+/-}.tar.gz

sed -i "s/$OLD_SESSION_HASH/$SESSION_HASH/" void-packages/srcpkgs/session-desktop/template

git add -A
git commit -q -m "v${2/+/-}"
git push -q --set-upstream origin "v${2/+/-}"

echo "Pushed v${2/+/-} to upstream"

git checkout -q master
